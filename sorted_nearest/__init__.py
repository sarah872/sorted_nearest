__version__ = "0.0.5"


try:
    from sorted_nearest.src.sorted_nearest import (nearest_previous_nonoverlapping,
                                                   nearest_next_nonoverlapping,
                                                   nearest_nonoverlapping,
                                                   find_clusters,
                                                   merge_sort_overlapping_and_nearest)

except ImportError:
    pass
