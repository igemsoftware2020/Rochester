import pandas as pd
import sys
import numpy as np
import itertools

# the combinedLOR will be compared to best. I initially am setting best to 0
best = 0


# Function #1
def subset_sum(weightedLOR, weights, partial_WLOR=[],
               partial_weights=[]):  # creating a function to subset the data (partials)
    global best

    if 2 <= len(partial_WLOR) <= 8:  # subsets (partials) will be between 2 and 6 biomarkers long
        sumWLOR = sum(partial_WLOR)  # sum of the weighted LOR in the subset
        sumWeight = sum(partial_weights)  # sum of the weighted LOR in the subset

        combinedLOR = sumWLOR / sumWeight  # using the sums from above to calculated a combined weighted LOR for this subset

        if combinedLOR > best:  # if the combined LOR is greater than best, then best is assigned the value of the combinedLOR. This ensures that the model gives me the best combination
            print('{}\n{}\nsum = {}\n\n'.format(partial_WLOR, partial_weights, combinedLOR))
            best = combinedLOR

    if len(partial_WLOR) > 6:  # this makes it so that subsets with more than 6 biomarkers are not included
        return

    for i in range(len(weightedLOR)):  # for loop to created all possible combinations of the biomarkers
        n = weightedLOR[i]
        w = weights[i]
        remaining_WLOR = weightedLOR[i + 1:]  # remainder of values in WeightedLOR
        remaining_weight = weights[i + 1:]  # remainder of values in Weights
        subset_sum(remaining_WLOR, remaining_weight, partial_WLOR + [n], partial_weights + [w])


# Function #2
def coLOR(weightedLOR, weights):
    global best  # same concept with best as in Function #1
    best = 0
    z = list(zip(weightedLOR, weights))  # includes weightedLOR and weights in my subset
    for length in range(2, 7):  # will create combinations between 2 and 6 biomarkers
        for subset in itertools.combinations(z, length):  # creates the subsets
            sumWLOR = sum([pair[0] for pair in subset])  # sums the weighted LOR which are in position 0 in the array
            sumWeight = sum([pair[1] for pair in subset])  # sums the weights which are in position 1 in the array

            combinedLOR = sumWLOR / sumWeight  # calculated combined LOR for the subset

            if combinedLOR > best:  # same as Function #1. This ensures I get the best possible combination
                print('{subset}\nsum = {combinedLOR}\n\n'.format(subset=subset, combinedLOR=combinedLOR))
                best = combinedLOR


def main():
    # biomarkers = pd.read_csv(sys.argv[1]) #loading my dataframe in
    biomarkers = pd.read_excel(sys.argv[1])
    print(biomarkers)

    biomarkers['a'] = biomarkers['Sensitivity'] * biomarkers['Endo Sample']  # true positives
    biomarkers['b'] = biomarkers['Endo Sample'] - biomarkers['a']  # false negatives
    biomarkers['d'] = biomarkers['Specificity'] * biomarkers['Control Sample']  # true negatives
    biomarkers['c'] = biomarkers['Control Sample'] - biomarkers['d']  # false positives

    biomarkers['SE'] = ((1 / biomarkers['a']) + (1 / biomarkers['b']) + (1 / biomarkers['c']) + (1 / biomarkers['d'])) ** (
            1 / 2)  # calculating SE for each biomarkers, based on a,b,c,d

    biomarkers['Weight'] = 1 / (biomarkers['SE'] ** 2)  # weighting each biomarker
    biomarkers['LOR'] = np.log(biomarkers['Sensitivity'] * biomarkers['Specificity'] / (
            (1 - biomarkers['Sensitivity']) * (
                1 - biomarkers['Specificity'])))  # calculating log(odds ratio) for each biomarker

    biomarkers['WeightedLOR'] = biomarkers['Weight'] * biomarkers['LOR']  # weighting the log(OR) for each biomarker

    biomarkers.to_csv('output.csv')  # saving my new dataframe with all the columns I made above

    subset_sum(biomarkers['WeightedLOR'].to_numpy(), biomarkers['Weight'].to_numpy())  # running function #1
    print('*' * 100 + '\n')  # lets me distinguish between the results of the two different sets of code
    coLOR(biomarkers['WeightedLOR'].to_numpy(), biomarkers['Weight'].to_numpy())  # running function #2


if __name__ == '__main__':
    main()
