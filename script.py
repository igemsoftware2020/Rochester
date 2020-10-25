import pandas as pd
import sys
import random

best = 0

def subset_sum(weightedLOR, weights, partial_WLOR=[], partial_weights=[]):
    global best

    if 2 <= len(partial_WLOR) <= 6:
        sumWLOR = sum(partial_WLOR)
        sumWeight = sum(partial_weights)

        combinedLOR = sumWLOR/sumWeight

        if combinedLOR > best:
            print('{}\n{}\nsum = {}\n\n'.format(partial_WLOR, partial_weights, combinedLOR))
            best = combinedLOR

    if len(partial_WLOR) > 6:
        return

    for i in range(len(weightedLOR)):
        n = weightedLOR[i]
        w = weights[i]
        remaining_WLOR = weightedLOR[i+1:]
        remaining_weight = weights[i+1:]
        subset_sum(remaining_WLOR, remaining_weight, partial_WLOR + [n], partial_weights + [w])


def main():
    odds_ratio = [round(random.random() * 10, 5) for i in range(15)]
    weights = [round(random.random() * 5, 5) for i in range(15)]

    print(odds_ratio)
    print(weights)
    print()

    subset_sum(odds_ratio, weights)

if __name__ == '__main__':
    main()
