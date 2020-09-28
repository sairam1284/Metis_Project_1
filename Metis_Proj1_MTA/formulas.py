import pandas as pd
import sys

def get_data(week_nums):
    """ Takes a list of weeknums and pulls data from mta
    inputs = list of weeknums in format of: '190803'
    outputs = Joined Dataframe of all weeks
    """
    url = 'http://web.mta.info/developers/data/nyct/turnstile/turnstile_{}.txt'
    dfs = []
    for week_num in week_nums:
        file_url = url.format(week_num)
        dfs.append(pd.read_csv(file_url))
    output = pd.concat(dfs)
    return output


def Clean_Date(data_frame, column='DATE'):
    """
    Takes the Date column, converts to a date, adds Time component and adds a weekday Column
    input: Dataframe, Column Name
    output: Updated Dataframe with new columns
    """
    day_map = {0:'Mon', 1: 'Tue', 2: 'Wed', 3:'Thu', 4:'Fri', 5:'Sat', 6:'Sun'}
    
    data_frame['DATETIME'] = pd.to_datetime(data_frame['DATE'] + ' ' + data_frame['TIME'])
    data_frame['DATE']  = pd.to_datetime(data_frame['DATE'],format='%m/%d/%Y')
    data_frame['TIME']=pd.to_datetime(data_frame['TIME'], format='%H:%M:%S')

    data_frame['Weekday'] = data_frame[column].apply(lambda x: x.dayofweek)
    data_frame['Weekday'] = data_frame['Weekday'].map(day_map)
    return data_frame

def daytype(day):
    """Takes the day column and applies Weekday or Weekend
    input: Day
    output: Weekday or Weekend
    """
    if day == 'Sat' or day == 'Sun':
        return 'Weekend'
    else:
        return 'Weekday'

def convertTimeBuckets(time):

    """
    This function creates a new column that groups time intervals into categories:

    00:00 < late night <= 4:00
    4:00 < early risers <= 8:00
    8:00 < morning <= 12:00
    12:00 < afternoon <= 16:00
    16:00 < evening  <= 20:00
    20:00 < late night <= 00:00
    """

    hour = time.hour
    if hour > 20 or hour == 0:
        category = 'Late Night'
    elif hour > 16:
        category = 'Evening'
    elif hour > 12:
        category = 'Afternoon'
    elif hour > 8:
        category = 'Morning'
    elif hour > 4:
        category = 'Early Morning'
    elif hour > 0:
        category = 'Late Night'

    return category
