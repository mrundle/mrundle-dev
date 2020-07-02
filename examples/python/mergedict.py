#!/usr/bin/env python3

import copy
import json
import sys

from copy import deepcopy
from enum import IntEnum, auto
from doctest import testmod, master

class MergeLevel(IntEnum):
    '''
    In merging a supplementary dict into a primary, the following values
    represent different overwrite strategies that can be specified. Each
    level is inclusive of the previous. See the doctests for the `merge`
    function for examples.
    '''
    # No values allowed to be overwritten (default)
    NONE   = auto()
    # Allows overwrite of non-dict values for a matching key
    LEAVES = auto()
    # Allows overwrite of dicts for matching keys
    TRUNKS = auto()

# merge a supplementary dict into a main dict
def merge(main, supp, overwrite=MergeLevel.NONE):
    """
    Merge a supplementary dict into main dict, with a given overwrite level.

    Args:
        main (dict): mutated via a merging in of `supp`
        supp (dict): merged into `main`, and is not mutated
        overwrite (enum MergeLevel): specification of merge overwrite level

    Return:
        None: the `main` input dict is mutated directly

    Usage and Doctests:

        The `doctest` module is employed below to exhibit working examples of usage
        alongside descriptions of functionality.

        At its most basic, the function will add new keys from `supp` into `main`.

        >>> main = {
        ...     'a': 0,
        ... }
        >>> supp = {
        ...     'b': 0,
        ... }
        >>> merge(main, supp)
        >>> main == {
        ...     'a': 0,
        ...     'b': 0,
        ... }
        True

        When the main and supplementary dicts are found to share keys, and the value
        of those keys is another dict, the merge will recurse. If the values of
        matching keys differ in type, there are three supported options:

            MergeLevel.NONE: only add new keys; never overwrite values
            MergeLevel.LEAVES: overwrite values, but only non-dicts
            MergeLevel.TRUNKS: overwrite values, including dicts

        The following examples show practical implications of each option. The
        following dictionaries represent the supplementary dict (`supp`), which
        will be merged into `main`.

        >>> main = {
        ...     'a': {
        ...         'a1': {
        ...             'a2': {
        ...                 'a3': 0,
        ...             },
        ...         },
        ...     },
        ...     'b': {
        ...         'b1': 0,
        ...     },
        ... }
        >>> supp = {
        ...     'a': 'xyz',
        ...     'b': {
        ...         'b1': 1,
        ...         'b2': 1,
        ...     },
        ... }

        First, we'll consider the default, MergeLevel.NONE. Since no values are
        allowed to be overwritten, the only change will be the addition of a brand
        new key-value pair.

        >>> _main = deepcopy(main)
        >>> merge(_main, supp)
        >>> assert _main == {
        ...     'a': { # preserved by MergeLevel.NONE
        ...         'a1': {
        ...             'a2': {
        ...                 'a3': 0,
        ...             },
        ...         },
        ...     },
        ...     'b': {
        ...         'b1': 0, # preserved by MergeLevel.NONE
        ...         'b2': 1, # new!
        ...     },
        ... }

        Next, we'll consider MergeLevel.LEAVES. Here, non-dict keys, like strings,
        integers, or arrays, can be overwritten. Since each merge level is inclusive
        of the previous, changes from the last example will be made here too.


        >>> _main = deepcopy(main)
        >>> merge(_main, supp, MergeLevel.LEAVES)
        >>> assert _main == {
        ...     'a': { # preserved by MergeLevel.NONE
        ...         'a1': {
        ...             'a2': {
        ...                 'a3': 0,
        ...             },
        ...         },
        ...     },
        ...     'b': {
        ...         'b1': 1, # changed!
        ...         'b2': 1, # new!
        ...     },
        ... }

        Finally, we'll consider the most aggressive setting, MergeLevel.TRUNKS.
        This allows the chopping off of dicts in the main blob when the supplementary
        dict maps a non-dict value to a shared key.

        >>> _main = deepcopy(main)
        >>> merge(_main, supp, MergeLevel.TRUNKS)
        >>> assert _main == {
        ...     'a': 'xyz', # overwritten!
        ...     'b': {
        ...         'b1': 1, # changed!
        ...         'b2': 1, # new!
        ...     },
        ... }
    """

    for d in (main, supp):
        if not isinstance(d, dict):
            return

    for k, v in supp.items():
        if k not in main:
            """foo"""
            main[k] = v
        else:
            if main[k] == v:
                continue
            if isinstance(main[k], dict):
                if isinstance(v, dict):
                    merge(main[k], v, overwrite)
                elif overwrite == MergeLevel.TRUNKS:
                    main[k] = v
                else:
                    continue
            elif overwrite >= MergeLevel.LEAVES:
                main[k] = v


if __name__ == '__main__':
    res = testmod(name='merge')
    failed = res.failed
    passed = res.attempted - res.failed
    print('{}: {}/{} doctests passing'.format(
        'ERROR' if failed > 0 else 'OK',
        passed,
        passed + failed
    ))
    # exit non-zero on any failure
    sys.exit(failed)


