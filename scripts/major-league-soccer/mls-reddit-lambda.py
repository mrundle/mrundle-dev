#!/usr/bin/env python3

DESCRIPTION = f"""\
This script fetches match details from the public MLS API for a given period
of time. By default, it will use a window of -2 days and +5. To accept defaults,
you can run the script with no arguments.

As of writing, the MLS API is not publicly documented or committed to be
maintained in its current form. API changes may change without warning, which
will break this script. The MLS API currently also does not require
authentication, which is something else that could change in the future.

This script attempts to make as few calls as possible to the API. Results are
cached for multiple repeated calls.
"""

import warnings
warnings.filterwarnings('ignore')

import argparse
import codecs
import datetime
import json
import os
import requests
import sys

# installed via pip
import dateutil
import pytz
import praw

# general
DEBUG_LOGGING = False
DEFAULT_DATA_DIR = '/tmp'
DEFAULT_TIMEZONE = 'US/Eastern'

# reddit
REDDIT_USERNAME = "MLS_Reddit_Bot"
REDDIT_SUBREDDIT = "MLS_Reddit_Bot"

# mls
DEFAULT_CATEGORIES = [ # match["competition"]["slug"]
    "mls-regular-season",
    "mls-cup-playoffs",
    "mls-all-star-game",
]
SUPPORTED_CATEGORIES = [
    "campeones-cup",
    "canadian-championship",
    "concacaf-champions-league",
    "concacaf-nations-league",
    "friendly",
    "gold-cup",
    "international-friendly",
    "leagues-cup",
    "mls-all-star-game",
    "mls-cup-playoffs",
    "mls-regular-season",
    "other-club-friendlies",
    "u-s-open-cup"
]


class MlsMatchSummary(object):
    def __init__(self, json_api_data, tz=DEFAULT_TIMEZONE):
        self.data = json_api_data
        self.tz_str = tz
        # see ./schema-examples/match.json
        d = self.data
        self.id = d["optaId"]
        self.home_team = d["home"]["fullName"]
        self.away_team = d["away"]["fullName"]
        self.venue = d["venue"]["name"]
        self.city = d["venue"]["city"]
        if d["isTimeTbd"]:
            self.date = 'TBD'
        else:
            self.date = dateutil.parser.parse(d["matchDate"])

    def __repr__(self):
        """
        Return string like:
            Saturday March 23 2024, 08:30 PM EDT: D.C. United @ St. Louis CITY SC (CITYPARK, St. Louis, MO)
        """
        ts = self.start_timestamp()
        return f'{ts}: {self.away_team} @ {self.home_team} ({self.venue}, {self.city})'

    def start_timestamp(self):
        """
        Returns string like:
            Saturday March 23 2024, 07:30 PM CDT
        """
        tz = pytz.timezone(self.tz_str)
        dt = self.date.astimezone(tz=tz)
        return dt.strftime(f'%A %B %d %Y, %I:%M %p {dt.tzname()}')

    def starts_in_n_minutes(self, n=5):
        now = datetime.datetime.now(datetime.timezone.utc)
        delta = self.date - now
        seconds_til_start = delta.total_seconds()
        return seconds_til_start <= (n * 60)

    def is_ended(self):
        return self.data["is_final"]


def warn(msg):
    sys.stderr.write(f'WARNING: {msg}\n')


def debug(msg):
    if DEBUG_LOGGING:
        sys.stderr.write(f'DEBUG: {msg}\n')


# TODO use this, more granular stats
def fetch_match_details(id, outdir):
    outfile = os.path.join(outdir, f'match-{id}')
    url=f'https://stats-api.mlssoccer.com/v1/matches?&match_game_id={id}&include=away_club_match&include=home_club_match&include=venue&include=home_club&include=away_club'
    debug(f'fetching from {url}')
    response = requests.get(url)
    data = response.json()
    with open(outfile, 'w') as f:
        json.dump(data, f, indent=4)
        debug(f'wrote details for match id {id} to {outfile}')


def fetch_matches(start_dt, end_dt, tz, categories, outdir, force):
    start_str = start_dt.strftime("%Y-%m-%d")
    end_str = end_dt.strftime("%Y-%m-%d")

    data = {}

    # skip fetch if we already have, unless --force is requested
    outfile = os.path.join(outdir, f'mls-matches-{start_str}_{end_str}')
    if not force and os.path.exists(outfile):
        debug(f'skipping fetch, data exists')
        data = json.load(open(outfile, 'r'))
    else:
        # make the api call
        data = []
        url=f"https://sportapi.mlssoccer.com/api/matches?culture=en-us&dateFrom={start_str}&dateTo={end_str}"
        debug(f'fetching from {url}')
        response = requests.get(url)
        data = response.json()

        # write the
        with open(outfile, 'w') as f:
            debug(f'writing to {outfile}')
            json.dump(data, f, indent=4)

    # filter
    result = []
    for match in data:
        try:
            if match["competition"]["slug"] in categories:
                result.append(MlsMatchSummary(match, tz=tz))
        except KeyError:
            warn("missing competition category slug")
            pass

    return result


def get_reddit_client():
    # authenticate and gain client; environment variables expected are:
    #    praw_client_id = ...
    #    praw_client_secret = ...
    #    praw_password = ...
    #    praw_username = ...
    client = praw.Reddit(
        redirect_uri=f"https://www.reddit.com/r/{REDDIT_SUBREDDIT}/",
        user_agent=f"MLS_Match_Thread_Bot by u/{REDDIT_USERNAME}",
    )
    assert client.user.me() == REDDIT_USERNAME, "failed to authenticate"
    return client


def parse_args():
    parser = argparse.ArgumentParser(
        description=DESCRIPTION,
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    today = datetime.date.today()
    #tomorrow = today + datetime.timedelta(days=1)
    parser.add_argument("--start",
                        default=str(today - datetime.timedelta(days=2)),
                        type=str,
                        help="start date")
    parser.add_argument("--end",
                        default=str(today + datetime.timedelta(days=5)),
                        type=str,
                        help="start date")
    parser.add_argument("--tz",
                        default=DEFAULT_TIMEZONE,
                        type=str,
                        help="output timezone")
    parser.add_argument("--data-directory",
                        default=DEFAULT_DATA_DIR,
                        help="data directory")
    parser.add_argument("--categories",
                        default=DEFAULT_CATEGORIES,
                        help="competition category")
    parser.add_argument("--show-timezones",
                        action='store_true',
                        help="list all valid timezone strings and exit")
    parser.add_argument("--show-categories",
                        action='store_true',
                        help="list all valid categories and exit")
    parser.add_argument("-f", "--force",
                        action='store_true',
                        help="force a fetch of fresh data; by default, this" \
                            "script prefers cached results")
    parser.add_argument("-d", "--debug",
                        action='store_true',
                        help="show debug log messages")
    args = parser.parse_args()
    args.start = dateutil.parser.parse(args.start)
    args.end = dateutil.parser.parse(args.end)

    if args.show_timezones:
        print('TIMEZONES:')
        for tz in pytz.all_timezones_set:
            print(f'\t* {tz}')
        sys.exit(1)
    elif args.show_categories:
        print('CATEGORIES:')
        for cat in SUPPORTED_CATEGORIES:
            print(f'\t* {cat}')
        sys.exit(1)

    try:
        pytz.timezone(args.tz)
    except pytz.exceptions.UnknownTimeZoneError as e:
        sys.stderr.write(f"unknown timezone '{args.tz}', try {sys.argv[0]} --show-timezones\n")
        sys.exit(1)

    #if args.debug:
    if True:
        global DEBUG_LOGGING
        DEBUG_LOGGING = True

    os.makedirs(args.data_directory, exist_ok=True)

    return args


def main():
    args = parse_args() # TODO remove, or re-introduce cli mode
    reddit = get_reddit_client()
    subreddit = reddit.subreddit(REDDIT_SUBREDDIT)

    matches = fetch_matches(
        args.start,
        args.end,
        args.tz,
        args.categories,
        args.data_directory,
        args.force)

    for m in matches:
        test_post_text+=f"\n* {m}\n"
        print(m)
        if m.starts_in_n_minutes(15):
            """
            TODO:
                1. Record created match threads (by id) in AWS DDB.
                2. Keep attempting creation until success.
                3. After match finishes, lock post and create post-match thread.
                (Maybe)
                4. Eventually: Log game stats and updates to each game thread,
                via integration with fetch_match_details()
                5. Move helper code into the lambda layer, clean up function.
            """
            submission = subreddit.submit(
                title=f'Match thread: {m.away_team} @ {m.home_team},
                selftext=str(m))
            debug(f'Posted https://www.reddit.com/r/MLS_Reddit_Bot/comments/{submission}')

def lambda_handler(event, context):
    try:
        main()
        return {
            'statusCode': 200,
            'body': 'OK',
        }
    except Exception as e:
        return {
            'statusCode': 400,
            'body': str(e),
        }


if __name__ == '__main__':
    error("only meant to be run via lambda, for now")
    exit(1)
