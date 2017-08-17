-- "Big tuple" stress test for monad comprehensions

{-# OPTIONS_GHC -XMonadComprehensions -XTransformListComp -XParallelListComp #-}

module Main where

main = putStrLn (show output)
  where
    output = [ x0 + x1 + x2 + x3 + x4 + x5 + x6 + x7 + x8 + x9 +
               x10 + x11 + x12 + x13 + x14 + x15 + x16 + x17 + x18 + x19 +
               x20 + x21 + x22 + x23 + x24 + x25 + x26 + x27 + x28 + x29 +
               x30 + x31 + x32 + x33 + x34 + x35 + x36 + x37 + x38 + x39 +
               x40 + x41 + x42 + x43 + x44 + x45 + x46 + x47 + x48 + x49 +
               x50 + x51 + x52 + x53 + x54 + x55 + x56 + x57 + x58 + x59 +
               x60 + x61 + x62 + x63 + x64 + x65 + x66 + x67 + x68 + x69 +
               x70 + x71 + x72 + x73 + x74 + x75 + x76 + x77 + x78 + x79 +
               x80 + x81 + x82 + x83 + x84 + x85 + x86 + x87 + x88 + x89 +
               x90 + x91 + x92 + x93 + x94 + x95 + x96 + x97 + x98 + x99 +
               y
             | x0 <- [0], x1 <- [1], x2 <- [2], x3 <- [3], x4 <- [4]
             , x5 <- [5], x6 <- [6], x7 <- [7], x8 <- [8], x9 <- [9]
             , x10 <- [0], x11 <- [1], x12 <- [2], x13 <- [3], x14 <- [4]
             , x15 <- [5], x16 <- [6], x17 <- [7], x18 <- [8], x19 <- [9]
             , x20 <- [0], x21 <- [1], x22 <- [2], x23 <- [3], x24 <- [4]
             , x25 <- [5], x26 <- [6], x27 <- [7], x28 <- [8], x29 <- [9]
             , x30 <- [0], x31 <- [1], x32 <- [2], x33 <- [3], x34 <- [4]
             , x35 <- [5], x36 <- [6], x37 <- [7], x38 <- [8], x39 <- [9]
             , x40 <- [0], x41 <- [1], x42 <- [2], x43 <- [3], x44 <- [4]
             , x45 <- [5], x46 <- [6], x47 <- [7], x48 <- [8], x49 <- [9]
             , x50 <- [0], x51 <- [1], x52 <- [2], x53 <- [3], x54 <- [4]
             , x55 <- [5], x56 <- [6], x57 <- [7], x58 <- [8], x59 <- [9]
             , x60 <- [0], x61 <- [1], x62 <- [2], x63 <- [3], x64 <- [4]
             , x65 <- [5], x66 <- [6], x67 <- [7], x68 <- [8], x69 <- [9]
             , x70 <- [0], x71 <- [1], x72 <- [2], x73 <- [3], x74 <- [4]
             , x75 <- [5], x76 <- [6], x77 <- [7], x78 <- [8], x79 <- [9]
             , x80 <- [0], x81 <- [1], x82 <- [2], x83 <- [3], x84 <- [4]
             , x85 <- [5], x86 <- [6], x87 <- [7], x88 <- [8], x89 <- [9]
             , x90 <- [0], x91 <- [1], x92 <- [2], x93 <- [3], x94 <- [4]
             , x95 <- [5], x96 <- [6], x97 <- [7], x98 <- [8], x99 <- [9]
             , then take 4
             | y <- [10] ]