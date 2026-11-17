Netflix Titles Data Cleaning (MySQL)

I used MySQL to clean and standardize the Netflix Movies and TV Shows dataset so it is ready for analysis and visualization. Raw CSV files usually have hidden formatting issues, missing entries, and text encoding glitches that break queries or skew charts if you do not fix them first.

What I Did

- Created a Staging Table: Before changing anything, I copied the raw data into a separate staging table (netflix_titles2) so the original file stayed untouched.
- Checked for Duplicates: I checked show_id counts and used a ROW_NUMBER() window function across title, type, release year, and director to make sure there were no duplicate entries.
- Trimmed Extra Spaces: I ran TRIM() across all text columns to clear out hidden leading and trailing spaces.
- Fixed Garbled Text (Encoding Errors): While checking the director and cast columns, I noticed accented names were broken from a CSV encoding mismatch (for example, JosÃ© instead of José and GarcÃ-a instead of García). I converted those columns from latin1 back to utf8mb4 to restore the proper spelling.
- Cleaned Up Blank Values: Several rows had empty strings ('') in director, cast, country, and rating. I converted them to proper NULL values first, then used COALESCE() to label them as 'Unknown'.
- Checked Data Anomalies and Dates: I checked for any duration values accidentally shifted into the rating column, standardized the date_added values, and updated the column type to DATE.

Tools Used
- MySQL 8.0 / MySQL Workbench

Files Included
- netflix_titles.csv - The original raw dataset.
- netflix_data_cleaning.sql - The full SQL script with comments for each cleaning step.
- netflix_titles_cleaned.csv - The final cleaned dataset ready for analysis.

