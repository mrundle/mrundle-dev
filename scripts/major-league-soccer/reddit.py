#!/usr/bin/env python3
import os
import warnings
warnings.filterwarnings('ignore')

# https://praw.readthedocs.io/en/stable/getting_started/quick_start.html
import praw

USERNAME = "MLS_Reddit_Bot"
SUBREDDIT = "MLS_Reddit_Bot"

def get_reddit_client(config):
    # authenticate and gain client; there should be a praw.ini file like:
    #   [mls_bot_config]
    #   client_id=revokedpDQy3xZ
    #   client_secret=revokedoqsMk5nHCJTHLrwgvHpr
    #   password=invalidht4wd50gk
    #   username=fakebot1
    client = praw.Reddit("mls_bot_config",
        redirect_uri=f"https://www.reddit.com/r/{SUBREDDIT}/",
        user_agent=f"MLS_Match_Thread_Bot by u/{USERNAME}",
    )
    assert client.user.me() == USERNAME, "failed to authenticate"
    return client


def main():
    config = Config()
    print(config.client_id)
    reddit = get_reddit_client(config)
    subreddit = reddit.subreddit(SUBREDDIT)

    submission= subreddit.submit(
        title='Test post',
        selftext="""\
This is a test post submitted by the MLS_Match_Thread_Bot, via praw.

The ultimate goal here is to auto-submit match threads based on match
start times as provided by the mlssoccer.com API.""")

    print(f'https://www.reddit.com/r/MLS_Reddit_Bot/comments/{submission}')


if __name__ == '__main__':
    main()
