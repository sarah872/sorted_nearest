cimport sorted_nearest.src.csorted_nearest as cn

cimport cython

import numpy as np

@cython.boundscheck(False)
@cython.wraparound(False)
cpdef nearest(long [::1] l_s, long [::1] l_e, long [::1] r_s, long [::1] r_e):

    cdef int _continue = 1
    cdef int new_diff
    cdef int old_diff = cn.INT_MAX
    cdef int j = 0
    cdef int i = 0
    cdef int ZERO = 0
    cdef int length_l = len(l_s)
    cdef int length_r_minus_one = len(r_s) - 1

    output_arr_ridx = np.zeros(length_l, dtype=np.long)
    output_arr_dist = np.zeros(length_l, dtype=np.long)
    cdef long [::1] output_ridx
    cdef long [::1] output_dist

    output_ridx = output_arr_ridx
    output_dist = output_arr_dist

    # since the main loop checks j + 1, need this step for checking index zero
    while _continue:
        # print("while j == 0")
        if l_e[i] < r_s[0]:
            # print("  l_e[i] < r_s[0]")
            old_diff = r_s[0] - l_e[i]
            _continue = 0
        elif l_s[i] > r_e[0]:
            # print("  l_s[i] > r_e[0]")
            old_diff = l_s[i] - r_e[0]
            _continue = 0
        else: # overlapping
            # print("  overlapping")
            output_ridx[i] = 0
            output_dist[i] = 0
            i += 1

    while i < length_l and j < length_r_minus_one:

        if l_e[i] < r_s[j + 1]:
            # print("l_e[i] < r_s[j + 1]")
            new_diff = r_s[j + 1] - l_e[i]
            # print("  New diff:", new_diff, "old diff:", old_diff)
            if new_diff > old_diff:
                # print("  Pushing", i, j, old_diff)
                output_ridx[i] = j
                output_dist[i] = old_diff
                old_diff = cn.INT_MAX
                j -= 1
                i += 1
            else:
                j += 1
                old_diff = new_diff

        elif l_s[i] > r_e[j + 1]:
            # print("l_s[i] > r_e[j + 1]")
            new_diff = l_s[i] - r_e[j + 1]
            # print("  New diff:", new_diff, "old diff:", old_diff)
            if new_diff > old_diff:
                # print("  Pushing", i, j, old_diff)
                output_ridx[i] = j
                output_dist[i] = old_diff
                old_diff = cn.INT_MAX
                j -= 1
                i += 1
            else:
                j += 1
                old_diff = new_diff
        else: # overlapping
            # print("else")
            # print("  Pushing", i, j, 0)
            j += 1
            output_ridx[i] = j
            output_dist[i] = 0
            old_diff = cn.INT_MAX
            j -= 1
            i += 1


    # might be a tie against last and second last since we could not check j == len(r)
    # in prev loop
    cdef int second_last = len(r_s) - 2
    cdef int last = len(r_s) - 1
    cdef int sl_dist, l_dist
    while i < length_l:
        # print("we are here")
        if l_e[i] < r_s[second_last]:
            # print("l_e[i] < r_s[second_last]")
            # print(l_e[i], r_s[second_last])
            sl_dist = r_s[second_last] - l_e[i]
        elif l_s[i] > r_e[second_last]:
            # print("l_s[i] > r_e[second_last]")
            # print(l_s[i], r_e[second_last])
            sl_dist = l_s[i] - r_e[second_last]
        else:
            sl_dist = 0

        if l_e[i] < r_s[last]:
            # print("l_e[i] < r_s[last]")
            # print(l_e[i], r_s[last])
            l_dist = r_s[last] - l_e[i]
        elif l_s[i] > r_e[last]:
            # print("l_s[i] > r_e[last]")
            # print(l_s[i], r_e[last])
            l_dist = l_s[i] - r_e[last]
        else:
            # print("else ldist=0")
            l_dist = 0

        # print("sl_dist", sl_dist, "l_dist", l_dist)
        if sl_dist < l_dist:
            # print(" Pushing", second_last, sl_dist)
            output_ridx[i] = second_last
            output_dist[i] = sl_dist
        else:
            # print(" Pushing", last, l_dist)
            output_ridx[i] = last
            output_dist[i] = l_dist

        i += 1

    return output_arr_ridx, output_arr_dist



@cython.boundscheck(False)
@cython.wraparound(False)
cpdef nearest_nonoverlapping(long [::1] l_s, long [::1] l_e, long [::1] r_s, long [::1] r_e):

    cdef int _continue = 1
    cdef int new_diff
    cdef int old_diff = cn.INT_MAX
    cdef int j = 0
    cdef int i = 0
    cdef int ZERO = 0
    cdef int length_l = len(l_s)
    cdef int length_r_minus_one = len(r_s) - 1

    output_arr_ridx = np.ones(length_l, dtype=np.long) * -1
    output_arr_dist = np.ones(length_l, dtype=np.long) * -1
    cdef long [::1] output_ridx
    cdef long [::1] output_dist

    output_ridx = output_arr_ridx
    output_dist = output_arr_dist

    # since the main loop checks j + 1, need this step for checking index zero
    # print("while j == 0")
    if l_e[i] < r_s[0]:
        # print("  l_e[i] < r_s[0]")
        old_diff = r_s[0] - l_e[i]
    elif l_s[i] > r_e[0]:
        # print("  l_s[i] > r_e[0]")
        old_diff = l_s[i] - r_e[0]

    while i < length_l and j < length_r_minus_one:

        if l_e[i] < r_s[j + 1]:
            # print("l_e[i] < r_s[j + 1]")
            new_diff = r_s[j + 1] - l_e[i]
            # print("  New diff:", new_diff, "old diff:", old_diff)
            if new_diff > old_diff:
                # print("  Pushing", i, j, old_diff)
                output_ridx[i] = j
                output_dist[i] = old_diff
                old_diff = cn.INT_MAX
                j -= 1
                i += 1
            else:
                j += 1
                old_diff = new_diff

        elif l_s[i] > r_e[j + 1]:
            # print("l_s[i] > r_e[j + 1]")
            new_diff = l_s[i] - r_e[j + 1]
            # print("  New diff:", new_diff, "old diff:", old_diff)
            if new_diff > old_diff:
                # print("  Pushing", i, j, old_diff)
                output_ridx[i] = j
                output_dist[i] = old_diff
                old_diff = cn.INT_MAX
                j -= 1
                i += 1
            else:
                j += 1
                old_diff = new_diff
        else: # overlapping
            old_diff = cn.INT_MAX
            j += 1


    # might be a tie against last and second last since we could not check j == len(r)
    # in prev loop
    cdef int second_last = len(r_s) - 2
    cdef int last = len(r_s) - 1
    cdef int sl_dist, l_dist
    while i < length_l:
        # print("we are here")
        if l_e[i] < r_s[second_last]:
            # print("l_e[i] < r_s[second_last]")
            # print(l_e[i], r_s[second_last])
            sl_dist = r_s[second_last] - l_e[i]
        elif l_s[i] > r_e[second_last]:
            # print("l_s[i] > r_e[second_last]")
            # print(l_s[i], r_e[second_last])
            sl_dist = l_s[i] - r_e[second_last]
        else:
            sl_dist = cn.INT_MAX

        if l_e[i] < r_s[last]:
            # print("l_e[i] < r_s[last]")
            # print(l_e[i], r_s[last])
            l_dist = r_s[last] - l_e[i]
        elif l_s[i] > r_e[last]:
            # print("l_s[i] > r_e[last]")
            # print(l_s[i], r_e[last])
            l_dist = l_s[i] - r_e[last]
        else:
            # print("else ldist=0")
            l_dist = cn.INT_MAX

        # print("sl_dist", sl_dist, "l_dist", l_dist)
        if sl_dist < l_dist:
            # print(" Pushing", second_last, sl_dist)
            output_ridx[i] = second_last
            output_dist[i] = sl_dist
        elif sl_dist > l_dist:
            # print(" Pushing", last, l_dist)
            output_ridx[i] = last
            output_dist[i] = l_dist

        i += 1

    return output_arr_ridx, output_arr_dist



@cython.boundscheck(False)
@cython.wraparound(False)
cpdef nearest_previous(long [::1] l_s, long [::1] r_e):

    "Does not find overlapping"

    cdef int diff
    cdef int j = 0
    cdef int i = 0
    cdef int ZERO = 0
    cdef int length_l = len(l_s)
    cdef int length_r = len(r_e)

    output_arr_ridx = np.ones(length_l, dtype=np.long) * -1
    output_arr_dist = np.ones(length_l, dtype=np.long) * -1
    cdef long [::1] output_ridx
    cdef long [::1] output_dist

    output_ridx = output_arr_ridx
    output_dist = output_arr_dist

    # loop out of the leftones that have no entries in right previous
    while i < length_l and l_s[i] <= r_e[0]:
        i += 1

    while i < length_l and j < length_r:

        if l_s[i] > r_e[j]:
            output_dist[i] = l_s[i] - r_e[j]
            j += 1
        else:
            j -= 1
            output_ridx[i] = j
            i += 1

    return output_arr_ridx, output_arr_dist


@cython.boundscheck(False)
@cython.wraparound(False)
cpdef nearest_next(long [::1] l_e, long [::1] r_s):

    "Does not find overlapping"

    cdef int diff
    cdef int j = 0
    cdef int i = 0
    cdef int ZERO = 0
    cdef int length_l = len(l_e)
    cdef int length_r = len(r_s)

    output_arr_ridx = np.ones(length_l, dtype=np.long) * -1
    output_arr_dist = np.ones(length_l, dtype=np.long) * -1
    cdef long [::1] output_ridx
    cdef long [::1] output_dist

    output_ridx = output_arr_ridx
    output_dist = output_arr_dist

    # loop out of the rightmost that are not next to any in left
    while j < length_r and r_s[j] <= l_e[0]:
        j += 1

    while i < length_l and j < length_r:

        if l_e[i] < r_s[j]:
            output_dist[i] = r_s[j] - l_e[i]
            output_ridx[i] = j
            i += 1
        else:
            j += 1

    return output_arr_ridx, output_arr_dist
