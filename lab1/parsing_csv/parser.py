import csv
from os.path import splitext
import pandas as pd
import names
import random
import datetime
import json


class Parser:
    def __init__(self, file: str):
        self.file = file
        self.names = []
        self.length = self.get_csv_file_len()

    def get_columns(self):
        headers = []
        with open(self.file, "r") as read_obj:
            reader = csv.reader(read_obj)
            for row in reader:
                headers = row
                break

        return headers

    def reduce_rows(self, num: int):
        f = pd.read_csv(self.file)
        new_f = f[:int(num)]
        new_f.to_csv(self.file, index=False)

    def delete_spare_columns(self, other_file: str, foreign_key, key):
        values = []

        with open(other_file, 'r') as read_obj:
            reader = csv.DictReader(read_obj)

            for row in reader:
                values.append(row[foreign_key])

        values = list(set(values))

        with open(splitext(self.file)[0] + '_spare_' + '.csv', 'a', newline='') as write_obj:


            csv_writer = csv.DictWriter(write_obj, self.get_columns())

            values2 = []

            with open("parser_" + str(datetime.datetime.now()) + ".log", 'a') as logging:

                with open(self.file, 'r') as read_obj:
                    csv_reader = csv.DictReader(read_obj)
                    for row in csv_reader:
                        values2.append(row)

                for val in values:
                    for p in values2:
                        if p[key] == val:
                            logging.write(", ".join(p) + '\n')
                            csv_writer.writerow(p)

    def delete_columns(self, columns: str):
        f = pd.read_csv(self.file)
        left_columns = self.get_columns()
        left_columns.remove(columns)
        new_f = f[left_columns]
        new_f.to_csv(self.file, index=False)

    def delete_duplicate_column(self, column: str):
        with open(self.file, 'r') as in_file, open(splitext(self.file)[0] + '_nodup' + '.csv', 'w') as out_file:
            seen = set()  # set for fast O(1) amortized lookup
            csv_reader = csv.DictReader(in_file)

            csv_writer = csv.DictWriter(out_file,
                                        fieldnames=['Country', 'subset', 'question_label', 'answer', 'name'])
            for line in csv_reader:
                if line[column] in seen: continue  # skip duplicate

                seen.add(line[column])
                csv_writer.writerow(line)

    def append_columns(self, columns):
        with open(self.file, 'r') as read_obj, \
                open(splitext(self.file)[0] + '_append' + '.csv', 'w', newline='') as write_obj:

            csv_reader = csv.reader(read_obj)

            csv_writer = csv.writer(write_obj)

            for csv_row in csv_reader:
                csv_row.append(columns[random.randint(0, len(columns) - 2)][0])
                csv_writer.writerow(csv_row)

    def get_csv_file_len(self):
        lines = 0
        with open(self.file, 'r') as read_obj:
            reader = csv.reader(read_obj)
            lines = sum(1 for line in reader)
        return lines

    def fill_empty_column(self, data: list):


    def get_data_people(self, header: str):
        if not self.names:
            data = []

            print(self.length)
            for i in range(1000):
                data.append([names.get_full_name()])

            self.names = data

        return [header] + self.names
