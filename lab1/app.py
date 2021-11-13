from parsing_csv.parser import Parser
# from create_data import App
# import os
import sys

def show_help(opt = 0):
    if opt == 0:
        print('''Usage: db.py [options]
    -d [file]: delete column
    -a [data length] [file 1] [file 2]: append column to file
    -s [file] [file 2] [foreign key] [key]: remove spare rows from second table by foreign key
    -r [file] [data length]: remove rows
    -l [file] [key]: remove duplicates
    -x: run postgres server, authentication variables are taken from environment
        
        ''')


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("no argument specified!")
        exit(1)

    if sys.argv[1] == '-d' or sys.argv[1] == '--delete-column':
        delete_parser = Parser(sys.argv[2])

        for arg in (sys.argv[3:]):
            delete_parser.delete_columns(arg)

    elif sys.argv[1] == '-a' or sys.argv[1] == '--append-column':
        append_parser = Parser(sys.argv[3])
        names_list = append_parser.get_data_people(sys.argv[2])
        append_parser.append_columns(names_list)
        append_parser = Parser(sys.argv[4])
        append_parser.append_columns(names_list)

    elif sys.argv[1] == '-s' or sys.argv[1] == '--delete-spare-fk':
        delete_spare_parser = Parser(sys.argv[2])
        delete_spare_parser.delete_spare_columns(sys.argv[3], sys.argv[4], sys.argv[5])

    elif sys.argv[1] == '-r' or sys.argv[1] == '--reduce':
        reduce_parser = Parser(sys.argv[2])
        reduce_parser.reduce_rows(sys.argv[3])

    elif sys.argv[1] == '-l':
        delete_duplicate_parser = Parser(sys.argv[2])
        delete_duplicate_parser.delete_duplicate_column(sys.argv[3])

    # elif sys.argv[1] == '-x':
        # app = App(os.environ['DB_NAME'], os.environ['USER']. os.environ['PASSWORD'])

    elif sys.argv[1] == '-h':
        show_help()
    else:
        exit(2)
        print("unknown argument was passed!")

    exit(0)
