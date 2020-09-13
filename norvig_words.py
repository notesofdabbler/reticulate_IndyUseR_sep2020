#
# Function from Peter Norvig's notebook on How to do things with words
# https://github.com/norvig/pytudes/blob/master/ipynb/How%20to%20Do%20Things%20with%20Words.ipynb
# 
# Made a few tweaks to enable calling from R through reticulate. Note those with comments starting with ***
#


import re
import math
import random
import matplotlib.pyplot as plt
from collections import Counter
from itertools   import permutations
from functools   import lru_cache
from typing      import List, Tuple, Set, Dict, Callable

Word = str    # We implement words as strings
cat = ''.join # Function to concatenate strings together

# *** changed return to a tuple to enable use in segment function
def tokens(text) -> Tuple[Word]:
    """List all the word tokens (consecutive letters) in a text. Normalize to lowercase."""
    return tuple(re.findall('[a-z]+', text.lower()))

sentence = ' '.join # Function to join words with spaces


def sample(words, n=10) -> str:
    """Sample n random words from a list of words."""
    return [random.choice(words) for _ in range(n)]

class ProbabilityFunction:
    def __call__(self, outcome):
        """The probability of `outcome`."""
        if not hasattr(self, 'total'):
            self.total = sum(self.values())
        return self[outcome] / self.total
    
class Bag(Counter, ProbabilityFunction): 
    """A bag of words."""

#*** added the Pword argument to be able to call this from R
def Pwords(words: List[Word], Pword) -> float:
    "Probability of a sequence of words, assuming each word is independent of others."
    return Π(Pword(w) for w in words)

def Π(nums) -> float:
    "Multiply the numbers together.  (Like `sum`, but with multiplication.)"
    result = 1
    for num in nums:
        result *= num
    return result

def splits(text, start=0, end=20) -> Tuple[str, str]:
    """Return a list of all (first, rest) pairs; start <= len(first) <= L."""
    return [(text[:i], text[i:]) 
            for i in range(start, min(len(text), end)+1)]

#*** Added the Pword argument to be able to call this from R
@lru_cache(None)
def segment(text, WORDS) -> List[Word]:
    """Return a list of words that is the most probable segmentation of text."""
    Pword = Bag(WORDS)
    if not text: 
        return []
    else:
        candidates = ([first] + segment(rest, WORDS)
                      for (first, rest) in splits(text, 1))
        return max(candidates, key=lambda x: Pwords(x, Pword))