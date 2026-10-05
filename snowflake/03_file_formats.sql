-- File Format

create file format csv_format type=csv
field_delimiter=','
skip_header=1
field_optionally_enclosed_by='"'
null_if=('NULL','','null');
show file formats;
