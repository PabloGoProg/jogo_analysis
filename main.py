import pandas as pd
import sqlite3
import os
import os.path
import datetime


def main():
    print("SQLite runtime version:", sqlite3.sqlite_version)
    db_path = os.path.join(os.path.dirname(__file__), "data/database.sqlite")
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    # Get all table names
    result = cursor.execute(
        "SELECT name FROM sqlite_master WHERE type='table';"
    ).fetchall()[1:]
    print("Tables found:", result)

    # Load each table into a dictionary of DataFrames
    tables = {}
    for table_tuple in result:
        table_name = table_tuple[0]
        tables[table_name] = pd.read_sql_query(f"SELECT * FROM {table_name}", conn)
        print(
            f"✓ Loaded '{table_name}': {len(tables[table_name])} rows, {len(tables[table_name].columns)} columns"
        )

    conn.close()
    return tables


def fill_nulls(df: pd.DataFrame) -> pd.DataFrame:
    for column in df.columns:
        if df[column].isnull().sum() > 0:
            df[column].fillna(df[column].mode()[0], inplace=True)
    return df


def export_tables(tables_dict, output_path):
    conn = sqlite3.connect(output_path)
    for table_name, df in tables_dict.items():
        df.to_sql(table_name, conn, if_exists="replace", index=False)
        print(f"✓ Exported '{table_name}'")
    conn.close()
    print(f"Database saved to: {output_path}")


if __name__ == "__main__":
    dfs: dict[str, pd.DataFrame] = main()

    # Access tables like: dfs['table_name']
    # [17 - 30)
    # [30 - 49]
    # dates = print(dfs["Player"]["birthday"])

    ## Some information gathering to understand the data
    # print(dfs["Player"]["birthday"].min())
    # print(dfs["Player"]["birthday"].max())

    print(dfs["Player_Attributes"].info())
    # print(dfs["Player_Attributes"].isna().sum())
    # print(dfs["Player_Attributes"]["attacking_work_rate"].value_counts())
    # print(dfs["Player_Attributes"]["defensive_work_rate"].value_counts())

    # print(dfs["Match"].info())
    # print(dfs["Match"].isnull().sum())
    # print(dfs["Match"].isna().sum())

    ## replacing null values with the mode
    for tn in ["Player", "Player_Attributes"]:
        df = dfs[tn]
        dfs[tn] = fill_nulls(df)

    # JOIN df["Player"] and df["Player_Attributes"] on player_api_id
    attrs = dfs["Player_Attributes"].copy()
    attrs["date"] = pd.to_datetime(attrs["date"], errors="coerce")

    attrs_latest = attrs.sort_values(["player_api_id", "date"]).drop_duplicates(
        subset="player_api_id", keep="last"
    )

    dfs["Player_Attributes"] = attrs_latest

    ## Players with latest age
    players = dfs["Player"]

    players_with_latest_attr = players.merge(
        attrs_latest, on="player_api_id", how="left", suffixes=("", "_attr")
    )

    players_with_latest_attr["age"] = players_with_latest_attr["date"].map(
        lambda d: d.year
    ) - players_with_latest_attr["birthday"].map(
        lambda d: datetime.datetime.strptime(d, "%Y-%m-%d %H:%M:%S").year
    )

    players_age_dict = players_with_latest_attr.set_index("player_api_id")[
        "age"
    ].to_dict()

    dfs["Player_Attributes"]["age"] = dfs["Player_Attributes"]["player_api_id"].map(
        players_age_dict
    )

    ## Replacing weird values with the mode
    dfs["Player_Attributes"]["attacking_work_rate"] = dfs["Player_Attributes"][
        "attacking_work_rate"
    ].map(
        lambda x: (
            dfs["Player_Attributes"]["attacking_work_rate"].mode()[0]
            if x not in ["low", "medium", "high"]
            else x
        )
    )

    dfs["Player_Attributes"]["defensive_work_rate"] = dfs["Player_Attributes"][
        "defensive_work_rate"
    ].map(
        lambda x: (
            dfs["Player_Attributes"]["defensive_work_rate"].mode()[0]
            if x not in ["low", "medium", "high"]
            else x
        )
    )

    ## Replacing labels with numerical values
    dfs["Player_Attributes"]["attacking_work_rate"] = dfs["Player_Attributes"][
        "attacking_work_rate"
    ].replace(
        {"low": 33, "medium": 66, "high": 99},
    )

    dfs["Player_Attributes"]["defensive_work_rate"] = dfs["Player_Attributes"][
        "defensive_work_rate"
    ].replace({"low": 33, "medium": 66, "high": 99})

    print(dfs["Player_Attributes"]["attacking_work_rate"].value_counts())
    print(dfs["Player_Attributes"]["defensive_work_rate"].value_counts())

    positions = dfs["Match"].iloc[:, 11:55]
    dfs["Match"].drop(columns=positions.columns, inplace=True)

    for i in range(11):
        dfs["Match"][f"home_player_{i + 1}_position"] = None
        dfs["Match"][f"away_player_{i + 1}_position"] = None

    for idx, row in positions.iterrows():
        for i in range(22):
            x, y = row.iloc[i], row.iloc[i + 11]
            lbl = (
                f"home_player_{i + 1}_position"
                if i < 11
                else f"away_player_{i - 11 + 1}_position"
            )

            if y < 2.0:
                dfs["Match"].at[idx, lbl] = "Goalkeeper"
            elif y > 2.0 and y < 5.5:
                dfs["Match"].at[idx, lbl] = "Defender"
            elif y > 5.5 and (x < 3.5 or x > 6.5):
                dfs["Match"].at[idx, lbl] = "Sider"
            elif y > 9.5:
                dfs["Match"].at[idx, lbl] = "Forward"
            elif (y > 5.5 and y < 9.5) and (x > 3.5 and x < 6.5):
                dfs["Match"].at[idx, lbl] = "Midfielder"
            else:
                dfs["Match"].at[idx, lbl] = None

    print("-----------------Values count player positions----------------------------")
    print(dfs["Match"]["home_player_9_position"].value_counts())

    ## Calculate league level from https://www.uefa.com/nationalassociations/uefarankings/country/?year=2016

    print(dfs["League"]["name"].unique())

    league_rankings = {
        "Spain LIGA BBVA": 105.713,
        "Germany 1. Bundesliga": 80.177,
        "England Premier League": 76.284,
        "Italy Serie A": 70.439,
        "Portugal Liga ZON Sagres": 53.082,
        "France Ligue 1": 52.749,
        "Belgium Jupiler League": 40.000,
        "Netherlands Eredivisie": 35.563,
        "Switzerland Super League": 33.775,
        "Poland Ekstraklasa": 22.500,
        "Scotland Premier League": 17.300,
    }

    dfs["League"]["uefa_ranking"] = dfs["League"]["name"].map(league_rankings)

    dfs["League"]["level"] = pd.qcut(
        dfs["League"]["uefa_ranking"], q=4, labels=[1, 2, 3, 4]
    )

    print("-----------------------------------------------------------------")
    print(dfs["League"])

    export_tables(
        dfs, os.path.join(os.path.dirname(__file__), "data/processed_database.sqlite")
    )
