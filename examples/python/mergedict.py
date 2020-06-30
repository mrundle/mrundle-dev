#!/usr/bin/env python3

import copy
import json

def jprint(x):
    print(json.dumps(x, indent=4))

# merge a supplementary dict into a main dict
def merge(main, supp, overwrite_leaves=False, overwrite_trunks=False):
    """
    Merge a supplementary dict into a main dict, defaulting to no overwrites
    on collisions. As a very simple example, consider the following:

        MAIN = {
            'foo': {
                'bar': 1,
            },
        }
        SUPP = {
            'foo': {
                'baz': 1,
            },
        }
        merge(MAIN, SUPP)
        assert MAIN == {
            'foo': {
                'bar': 1,
                'baz': 1,
            },
        }

    Collisions are defined as cases where both dictionaries have matching
    keys, but different values that are *not* dicts (matching keys with
    dict values will result in a recursive merge call).

    The following keyword arguments support overwrites on collisions:

        - overwrite_leaves: In a collision where the main dicts "value"
                            is NOT a dict, the new value from the supplementary
                            dict will replace it.

        - overwrite_trunks: In a collision where the main dicts "value"
                            IS a dict, the new value from the supplementary
                            dict will replace it. Note that overwrite_trunks
                            implies overwrite_leaves.
    """
    oleaves = overwrite_leaves
    otrunks = overwrite_trunks

    # note: overwrite_trunks implies overwrite_trees
    for d in (main, supp):
        if not isinstance(d, dict):
            print('nodict')
            return

    for k, v in supp.items():
        # TODO if not gentle, overwrite values
        if k not in main:
            main[k] = v
        else:
            # key match; recurse or collide
            if main[k] == v:
                continue
            if isinstance(main[k], dict):
                if isinstance(v, dict):
                    # recurse
                    merge(
                        main[k],
                        v,
                        overwrite_leaves=oleaves,
                        overwrite_trunks=otrunks)
                elif otrunks:
                    main[k] = v
                else:
                    continue
            elif oleaves or otrunks:
                main[k] = v


def test_wrapper(func):
    """
    This wrapper function feeds a deepcopy of EXAMPLE_DICT into test functions,
    which will call merge() and make their own assertions about expected output.
    """
    EXAMPLE_DICT = {
        'foo': {
            'bar': {
                'baz': {
                    'xyz': 23,
                },
            },
        },
        'bar': 9,
    }
    def wrapper():
        main_dict = copy.deepcopy(EXAMPLE_DICT)
        func(main_dict)
    return wrapper

@test_wrapper
def test_basic_merge(main_dict):
    new_dict = copy.deepcopy(main_dict)
    new_dict['foo']['bar']['baz']['def'] = 12
    merge(main_dict, new_dict)
    b = {
        'foo': {
            'bar': {
                'baz': {
                    'xyz': 23,
                    'def': 12,
                },
            },
        },
        'bar': 9,
    }
    assert main_dict == b

@test_wrapper
def test_overwrite_leaves(main_dict):
    new_dict = {'bar': 12345}
    merge(main_dict, new_dict, overwrite_leaves=True)
    assert main_dict == {
        'foo': {
            'bar': {
                'baz': {
                    'xyz': 23,
                },
            },
        },
        'bar': 12345,
    }

@test_wrapper
def test_overwrite_trunks(main_dict):
    new_dict = {'foo': 10}
    merge(main_dict, new_dict, overwrite_trunks=True)
    assert main_dict == {
        'foo': 10,
        'bar': 9,
    }

if __name__ == '__main__':
    test_basic_merge()
    test_overwrite_leaves()
    test_overwrite_trunks()
    print('ok')

