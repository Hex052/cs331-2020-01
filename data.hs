-- data.hs
-- Glenn G. Chappell
-- Started: 2020-03-02
-- Updated: 2020-03-06
--
-- For CS F331 / CSCE A331 Spring 2020
-- Code from 3/2 & 3/6 - Haskell: Data

module Main where

import System.IO  -- for hFlush, stdout


main = do
    putStrLn ""
    putStrLn "This file contains sample code from March 2"
    putStrLn "& March 6, 2020, for the topic \"Haskell: Data\"."
    putStrLn "It will execute, but it is not intended to do anything"
    putStrLn "useful. See the source."
    putStrLn ""
    putStr   "Press ENTER to quit "
    hFlush stdout
    _ <- getLine
    return ()


-- ***** data Declaration *****


-- Define a new type with "data"

data Product = Pr String String  -- Product name, Manufacturer name
-- Above, the new type is "Product". "Pr" is a *constructor*. Here is a
-- value of type Product:
--   Pr "Sanka" "Kraft Foods"

-- Pattern matching works with constructors. We can use this to get a
-- String out of a Product.

pName :: Product -> String
pName (Pr pn _) = pn  -- Get product name

mName :: Product -> String
mName (Pr _ mn) = mn  -- Get manufacturer name

-- Try:
--   sanka = Pr "Sanka" "Kraft Foods"
--   pName sanka
--   mName sanka

-- Here are functions that do equality checking and conversion to String
-- for type Product.

sameProduct :: Product -> Product -> Bool
sameProduct (Pr pn1 mn1) (Pr pn2 mn2) = (pn1 == pn2) && (mn1 == mn2)

productToString :: Product -> String
productToString (Pr pn mn) = pn ++ " [made by " ++ mn ++ "]"

-- Try:
--   tide = Pr "Tide" "Procter & Gamble"
--   crest = Pr "Crest" "Procter & Gamble"
--   sameProduct tide crest
--   sameProduct tide tide
--   productToString crest


-- ***** Overloading & Type Classes *****


-- Overloading in Haskell is done via type classes. For each overloaded
-- function or operator, there is a corresponding type class. In order
-- to overload the function/operator for a type, that type must be in
-- the type class; we say it is an *instance* of the type class.

-- The equality (==) and inequality (/=) operators are overloaded for
-- instances of type class Eq. In order to overload these for type
-- Product, we make Product an instance of Eq. When we do so, we define
-- the == operator.

instance Eq Product where
    Pr pn1 mn1 == Pr pn2 mn2 = (pn1 == pn2) && (mn1 == mn2)

-- Try:
--   axe = Pr "Axe" "Unilever"
--   dove_soap = Pr "Dove" "Unilever"
--   dove_bar = Pr "Dove" "M&M/Mars"
--   axe == dove_soap
--   dove_soap == dove_bar
--   axe == axe
--   axe /= dove_soap
--   axe /= axe

-- Having defined the == operator, the /= operator is defined for us.
-- This is typical of the way type classes work. We could have defined
-- the /= operator ourselves, and then the == operator would have been
-- defined for us. We also have the option of defining both ourselves.

-- Function "show", which does conversion to String, is overloaded using
-- type class Show.

instance Show Product where
    show (Pr pn mn) = pn ++ " [made by " ++ mn ++ "]"

-- Try:
--   dove_soap = Pr "Dove" "Unilever"
--   show dove_soap
--   dove_soap
--   show dove_soap ++ " is not soap; it is a *beauty bar*."


-- ***** Options & Parametrization *****


-- In a data declaration, we can separate options with a vertical bar
-- (|). For example, if Haskell did not have type Bool, then we could
-- define it ourselves, as follows.

-- data Bool = True | False

-- A data declaration can be *parametrized*. The result is something
-- like a C++ class template: we can make a type using another type. For
-- example, if Haskell did not have Either, then we could define it
-- ourselves, as follows.

-- data Either a b = Left a | Right b

-- Putting these ideas together, we can define a Binary Tree.
-- Below, /vt is the value type.

data BT vt = BTEmpty | BTNode vt (BT vt) (BT vt)
-- Values given to BTNode:
-- - Value in node
-- - Left subtree
-- - Right subtree

-- Here are some simple functions using BT.

isEmptyBT :: BT a -> Bool
isEmptyBT BTEmpty = True
isEmptyBT (BTNode _ _ _) = False

rootValue :: BT a -> a
rootValue (BTNode v _ _) = v
rootValue BTEmpty = error "rootValue: given BT is empty"

leftSubtree :: BT a -> BT a
leftSubtree (BTNode _ lsub _) = lsub
leftSubtree BTEmpty = error "leftSubtree: given BT is empty"

rightSubtree :: BT a -> BT a
rightSubtree (BTNode _ _ rsub) = rsub
rightSubtree BTEmpty = error "rightSubtree: given BT is empty"

-- Try:
--   t1 = BTNode "Yo!" BTEmpty BTEmpty
--   t2 = BTEmpty
--   isEmptyBT t1
--   isEmptyBT t2
--   rootValue t1
--   rootValue t2


-- ***** Treesort *****


-- *Treesort* is a comparison sort that proceeds as follows: given a
-- list, insert each item into a Binary Search Tree. Then traverse the
-- tree (inorder) to get the final sorted list.

-- We can implement Treesort using our Binary Tree.

-- Note that Treesort has some efficiency problems. And our
-- implementation is rather inefficient -- even for Treesort. So
-- function "treesort" (below) is not really practical. But it is, I
-- think, an instructive example. (Also, it works.)

-- insert
-- Given a Binary Search Tree (represented as type "BT vt",
-- where vt is the value type) and an item, return the Binary Search
-- Tree with the item inserted.
--
-- In a type annotation, we must require that vt is in type class Ord,
-- since we compare is using the < operator.
insert :: (Ord vt) => BT vt -> vt -> BT vt
insert BTEmpty v = BTNode v BTEmpty BTEmpty
insert (BTNode v lsub rsub) vv
    | vv < v     = BTNode v (insert lsub vv) rsub
    | otherwise  = BTNode v lsub (insert rsub vv)

-- inorderTraverse
-- Given a Binary Tree, return a list of its items, in the order given
-- by an inorder traversal.
--
-- Note that, for a Binary Search Tree, an inorder traversal will be
-- sorted.
inorderTraverse :: BT vt -> [vt]
inorderTraverse BTEmpty = []
inorderTraverse (BTNode v lsub rsub) =
    inorderTraverse lsub ++ [v] ++ inorderTraverse rsub

-- Now we can write Treesort. A key realization is that, given function
-- "insert" (above), which inserts a single item into a Binary Search
-- Tree, we can insert a list of items using a fold operation.
-- Specifically, given a list xs, a Binary Search Tree containing all
-- items in xs is given by the following.
--   foldl insert BTEmpty xs

-- treesort
-- Return a sorted version of the given list. The sort is stable. The
-- Treesort algorithm is used.
treesort :: (Ord a) => [a] -> [a]
treesort xs = inorderTraverse $ foldl insert BTEmpty xs

-- Try:
--   treesort []
--   treesort [5,4,3,2,1,2,3,4,5,4,3,2,1]
--   treesort ["elk","pig","dog","yak","rat","cow","ape","cat","bat"]
--   treesort ([1..50000] ++ [1..50000])

-- The last line above illustrates the efficiency troubles with function
-- treesort. In contrast, check out the following.

-- Try:
--   import Data.List
--   sort ([1..50000] ++ [1..50000])

