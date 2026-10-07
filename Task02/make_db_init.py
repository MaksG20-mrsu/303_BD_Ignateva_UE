import csv
import os

# Функция для экранирования апострофов в тексте (чтобы SQL не ломался)
def escape_sql(value):
    if value is None:
        return ""
    return str(value).replace("'", "''")

# Папка с исходными файлами (относительно корня проекта)
DATA_DIR = "dataset"
OUTPUT_FILE = "Task02/db_init.sql"

# Описание таблиц: (имя таблицы, имя файла, колонки, разделитель)
tables = [
    # movies: movieId, title, genres
    ("movies", "movies.csv", ["movieId", "title", "genres"], ","),
    # ratings: userId, movieId, rating, timestamp
    ("ratings", "ratings.csv", ["userId", "movieId", "rating", "timestamp"], ","),
    # tags: userId, movieId, tag, timestamp
    ("tags", "tags.csv", ["userId", "movieId", "tag", "timestamp"], ","),
    # users: id, name, email, gender, register_date, occupation (разделитель |)
    ("users", "users.txt", ["id", "name", "email", "gender", "register_date", "occupation"], "|")
]

with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
    f.write("PRAGMA foreign_keys = OFF;\n")
    f.write("BEGIN TRANSACTION;\n")
    
    for table_name, filename, columns, delimiter in tables:
        # 1. Удаляем таблицу, если она есть
        f.write(f"DROP TABLE IF EXISTS {table_name};\n")
        
        # 2. Создаем таблицу. PRIMARY KEY только для колонки "id".
        cols_def_list = []
        for col in columns:
            if col == "id":
                cols_def_list.append(f"{col} INTEGER PRIMARY KEY")
            else:
                cols_def_list.append(f"{col} TEXT")
        
        cols_def = ", ".join(cols_def_list)
        f.write(f"CREATE TABLE {table_name} ({cols_def});\n")
        
        # 3. Загружаем данные
        filepath = os.path.join(DATA_DIR, filename)
        if not os.path.exists(filepath):
            print(f"Warning: {filepath} not found, skipping...")
            continue
            
        with open(filepath, "r", encoding="utf-8") as csvfile:
            reader = csv.reader(csvfile, delimiter=delimiter)
            header = next(reader) # пропускаем заголовок
            
            insert_sql = f"INSERT INTO {table_name} ({', '.join(columns)}) VALUES "
            values_list = []
            
            for row in reader:
                if len(row) != len(columns):
                    continue # пропускаем битые строки
                vals = ", ".join([f"'{escape_sql(v)}'" for v in row])
                values_list.append(f"({vals})")
                
                # Пишем пачками по 1000 строк
                if len(values_list) >= 1000:
                    f.write(insert_sql + ",\n".join(values_list) + ";\n")
                    values_list = []
            
            if values_list:
                f.write(insert_sql + ",\n".join(values_list) + ";\n")
    
    f.write("COMMIT;\n")

print(f"SQL script generated: {OUTPUT_FILE}")