{-# OPTIONS_GHC -XTemplateHaskell #-}

-- Copyright: (c) Magnus Therning, 2012
-- License: BSD3, found in the LICENSE file

module Main where

import Test.Framework
import Test.Framework.TH
import Test.Framework.Providers.HUnit
import Test.HUnit
import Data.ByteString
import qualified Codec.Binary.Base85 as B85
import qualified Codec.Binary.Base64 as B64
import qualified Codec.Binary.Base64Url as B64U
import qualified Codec.Binary.Base32 as B32
import qualified Codec.Binary.Base32Hex as B32H
import qualified Codec.Binary.Uu as Uu
import qualified Codec.Binary.Xx as Xx
import qualified Codec.Binary.Yenc as Y

-- {{{1 base85
case_b85encode = do
    -- foobar
    empty @=? B85.encode empty
    pack [65,99] @=? (B85.encode $ pack [102])
    pack [65,111,64] @=? (B85.encode $ pack [102,111])
    pack [65,111,68,83] @=? (B85.encode $ pack [102,111,111])
    pack [65,111,68,84,115] @=? (B85.encode $ pack [102,111,111,98])
    pack [65,111,68,84,115,64,47] @=? (B85.encode $ pack [102,111,111,98,97])
    pack [65,111,68,84,115,64,60,41] @=? (B85.encode $ pack [102,111,111,98,97,114])
    -- all zero
    pack [122] @=? (B85.encode $ pack [0,0,0,0])
    -- all space
    pack [121] @=? (B85.encode $ pack [32,32,32,32])
    -- double special
    pack [121,122] @=? (B85.encode $ pack [32,32,32,32,0,0,0,0])

case_b85decode = do
    -- foobar
    Right empty @=? B85.decode empty
    (Right $ pack [102]) @=? (B85.decode $ pack [65,99])
    (Right $ pack [102,111]) @=? (B85.decode $ pack [65,111,64])
    (Right $ pack [102,111,111]) @=? (B85.decode $ pack [65,111,68,83])
    (Right $ pack [102,111,111,98]) @=? (B85.decode $ pack [65,111,68,84,115])
    (Right $ pack [102,111,111,98,97]) @=? (B85.decode $ pack [65,111,68,84,115,64,47])
    (Right $ pack [102,111,111,98,97,114]) @=? (B85.decode $ pack [65,111,68,84,115,64,60,41])
    -- all zero
    (Right $ pack [0,0,0,0]) @=? (B85.decode $ pack [122])
    -- all space
    (Right $ pack [32,32,32,32]) @=? (B85.decode $ pack [121])
    -- double special
    (Right $ pack [32,32,32,32,0,0,0,0]) @=? (B85.decode $ pack [121,122])

-- {{{1 base64
case_b64encode = do
    -- foobar
    empty @=? B64.encode empty
    pack [90,103,61,61] @=? (B64.encode $ pack [102])
    pack [90,109,56,61] @=? (B64.encode $ pack [102,111])
    pack [90,109,57,118] @=? (B64.encode $ pack [102,111,111])
    pack [90,109,57,118,89,103,61,61] @=? (B64.encode $ pack [102,111,111,98])
    pack [90,109,57,118,89,109,69,61] @=? (B64.encode $ pack [102,111,111,98,97])
    pack [90,109,57,118,89,109,70,121] @=? (B64.encode $ pack [102,111,111,98,97,114])
    -- /++/
    pack [47,43,43,47] @=? (B64.encode $ pack [255,239,191])

case_b64decode = do
    -- foobar
    Right empty @=? B64.decode empty
    (Right $ pack [102]) @=? (B64.decode $ pack [90,103,61,61])
    (Right $ pack [102,111]) @=? (B64.decode $ pack [90,109,56,61])
    (Right $ pack [102,111,111]) @=? (B64.decode $ pack [90,109,57,118])
    (Right $ pack [102,111,111,98]) @=? (B64.decode $ pack [90,109,57,118,89,103,61,61])
    (Right $ pack [102,111,111,98,97]) @=? (B64.decode $ pack [90,109,57,118,89,109,69,61])
    (Right $ pack [102,111,111,98,97,114]) @=? (B64.decode $ pack [90,109,57,118,89,109,70,121])
    -- /++/
    (Right $ pack [255,239,191]) @=? (B64.decode $ pack [47,43,43,47])

-- {{{1 base64url
case_b64urlencode = do
    -- foobar
    empty @=? B64U.encode empty
    pack [90,103,61,61] @=? (B64U.encode $ pack [102])
    pack [90,109,56,61] @=? (B64U.encode $ pack [102,111])
    pack [90,109,57,118] @=? (B64U.encode $ pack [102,111,111])
    pack [90,109,57,118,89,103,61,61] @=? (B64U.encode $ pack [102,111,111,98])
    pack [90,109,57,118,89,109,69,61] @=? (B64U.encode $ pack [102,111,111,98,97])
    pack [90,109,57,118,89,109,70,121] @=? (B64U.encode $ pack [102,111,111,98,97,114])
    -- _--_
    pack [95,45,45,95] @=? (B64U.encode $ pack [255,239,191])

case_b64urldecode = do
    -- foobar
    Right empty @=? B64U.decode empty
    (Right $ pack [102]) @=? (B64U.decode $ pack [90,103,61,61])
    (Right $ pack [102,111]) @=? (B64U.decode $ pack [90,109,56,61])
    (Right $ pack [102,111,111]) @=? (B64U.decode $ pack [90,109,57,118])
    (Right $ pack [102,111,111,98]) @=? (B64U.decode $ pack [90,109,57,118,89,103,61,61])
    (Right $ pack [102,111,111,98,97]) @=? (B64U.decode $ pack [90,109,57,118,89,109,69,61])
    (Right $ pack [102,111,111,98,97,114]) @=? (B64U.decode $ pack [90,109,57,118,89,109,70,121])
    -- _--_
    (Right $ pack [255,239,191]) @=? (B64U.decode $ pack [95,45,45,95])

-- {{{1 base32
case_b32encode = do
    -- foobar
    empty @=? B32.encode empty
    pack [77,89,61,61,61,61,61,61] @=? (B32.encode $ pack [102])
    pack [77,90,88,81,61,61,61,61] @=? (B32.encode $ pack [102,111])
    pack [77,90,88,87,54,61,61,61] @=? (B32.encode $ pack [102,111,111])
    pack [77,90,88,87,54,89,81,61] @=? (B32.encode $ pack [102,111,111,98])
    pack [77,90,88,87,54,89,84,66] @=? (B32.encode $ pack [102,111,111,98,97])
    pack [77,90,88,87,54,89,84,66,79,73,61,61,61,61,61,61] @=? (B32.encode $ pack [102,111,111,98,97,114])

case_b32decode = do
    -- foobar
    Right empty @=? B32.decode empty
    (Right $ pack [102]) @=? (B32.decode $ pack [77,89,61,61,61,61,61,61])
    (Right $ pack [102,111]) @=? (B32.decode $ pack [77,90,88,81,61,61,61,61])
    (Right $ pack [102,111,111]) @=? (B32.decode $ pack [77,90,88,87,54,61,61,61])
    (Right $ pack [102,111,111,98]) @=? (B32.decode $ pack [77,90,88,87,54,89,81,61])
    (Right $ pack [102,111,111,98,97]) @=? (B32.decode $ pack [77,90,88,87,54,89,84,66])
    (Right $ pack [102,111,111,98,97,114]) @=? (B32.decode $ pack [77,90,88,87,54,89,84,66,79,73,61,61,61,61,61,61])

-- {{{1 base32hex
case_b32hencode = do
    -- foobar
    empty @=? B32H.encode empty
    pack [67,79,61,61,61,61,61,61] @=? (B32H.encode $ pack [102])
    pack [67,80,78,71,61,61,61,61] @=? (B32H.encode $ pack [102,111])
    pack [67,80,78,77,85,61,61,61] @=? (B32H.encode $ pack [102,111,111])
    pack [67,80,78,77,85,79,71,61] @=? (B32H.encode $ pack [102,111,111,98])
    pack [67,80,78,77,85,79,74,49] @=? (B32H.encode $ pack [102,111,111,98,97])
    pack [67,80,78,77,85,79,74,49,69,56,61,61,61,61,61,61] @=? (B32H.encode $ pack [102,111,111,98,97,114])

case_b32hdecode = do
    -- foobar
    Right empty @=? B32H.decode empty
    (Right $ pack [102]) @=? (B32H.decode $ pack [67,79,61,61,61,61,61,61])
    (Right $ pack [102,111]) @=? (B32H.decode $ pack [67,80,78,71,61,61,61,61])
    (Right $ pack [102,111,111]) @=? (B32H.decode $ pack [67,80,78,77,85,61,61,61])
    (Right $ pack [102,111,111,98]) @=? (B32H.decode $ pack [67,80,78,77,85,79,71,61])
    (Right $ pack [102,111,111,98,97]) @=? (B32H.decode $ pack [67,80,78,77,85,79,74,49])
    (Right $ pack [102,111,111,98,97,114]) @=? (B32H.decode $ pack [67,80,78,77,85,79,74,49,69,56,61,61,61,61,61,61])

-- {{{1 uu
case_uuencode = do
    -- foobar
    empty @=? Uu.encode empty
    pack [57,64] @=? (Uu.encode $ pack [102])
    pack [57,70,92] @=? (Uu.encode $ pack [102,111])
    pack [57,70,93,79] @=? (Uu.encode $ pack [102,111,111])
    pack [57,70,93,79,56,64] @=? (Uu.encode $ pack [102,111,111,98])
    pack [57,70,93,79,56,70,36] @=? (Uu.encode $ pack [102,111,111,98,97])
    pack [57,70,93,79,56,70,37,82] @=? (Uu.encode $ pack [102,111,111,98,97,114])

case_uudecode = do
    -- foobar
    Right empty @=? Uu.decode empty
    (Right $ pack [102]) @=? (Uu.decode $ pack [57,64])
    (Right $ pack [102,111]) @=? (Uu.decode $ pack [57,70,92])
    (Right $ pack [102,111,111]) @=? (Uu.decode $ pack [57,70,93,79])
    (Right $ pack [102,111,111,98]) @=? (Uu.decode $ pack [57,70,93,79,56,64])
    (Right $ pack [102,111,111,98,97]) @=? (Uu.decode $ pack [57,70,93,79,56,70,36])
    (Right $ pack [102,111,111,98,97,114]) @=? (Uu.decode $ pack [57,70,93,79,56,70,37,82])

-- {{{1 xx
case_xxencode = do
    -- foobar
    empty @=? Xx.encode empty
    pack [78,85] @=? (Xx.encode $ pack [102])
    pack [78,97,119] @=? (Xx.encode $ pack [102,111])
    pack [78,97,120,106] @=? (Xx.encode $ pack [102,111,111])
    pack [78,97,120,106,77,85] @=? (Xx.encode $ pack [102,111,111,98])
    pack [78,97,120,106,77,97,50] @=? (Xx.encode $ pack [102,111,111,98,97])
    pack [78,97,120,106,77,97,51,109] @=? (Xx.encode $ pack [102,111,111,98,97,114])

case_xxdecode = do
    -- foobar
    Right empty @=? Xx.decode empty
    (Right $ pack [102]) @=? (Xx.decode $ pack [78,85])
    (Right $ pack [102,111]) @=? (Xx.decode $ pack [78,97,119])
    (Right $ pack [102,111,111]) @=? (Xx.decode $ pack [78,97,120,106])
    (Right $ pack [102,111,111,98]) @=? (Xx.decode $ pack [78,97,120,106,77,85])
    (Right $ pack [102,111,111,98,97]) @=? (Xx.decode $ pack [78,97,120,106,77,97,50])
    (Right $ pack [102,111,111,98,97,114]) @=? (Xx.decode $ pack [78,97,120,106,77,97,51,109])

-- {{{1 yenc
case_yenc_encode = do
    -- foobar
    empty @=? Y.encode empty
    pack [144] @=? (Y.encode $ pack [102])
    pack [144,153] @=? (Y.encode $ pack [102,111])
    pack [144,153,153] @=? (Y.encode $ pack [102,111,111])
    pack [144,153,153,140] @=? (Y.encode $ pack [102,111,111,98])
    pack [144,153,153,140,139] @=? (Y.encode $ pack [102,111,111,98,97])
    pack [144,153,153,140,139,156] @=? (Y.encode $ pack [102,111,111,98,97,114])
    -- expanded chars
    pack [61,64] @=? (Y.encode $ pack [214])
    pack [61,74] @=? (Y.encode $ pack [224])
    pack [61,77] @=? (Y.encode $ pack [227])
    pack [61,125] @=? (Y.encode $ pack [19])

case_yenc_decode = do
    -- foobar
    Right empty @=? Y.decode empty
    (Right $ pack [102]) @=? (Y.decode $ pack [144])
    (Right $ pack [102,111]) @=? (Y.decode $ pack [144,153])
    (Right $ pack [102,111,111]) @=? (Y.decode $ pack [144,153,153])
    (Right $ pack [102,111,111,98]) @=? (Y.decode $ pack [144,153,153,140])
    (Right $ pack [102,111,111,98,97]) @=? (Y.decode $ pack [144,153,153,140,139])
    (Right $ pack [102,111,111,98,97,114]) @=? (Y.decode $ pack [144,153,153,140,139,156])
    -- expanded chars
    (Right $ pack [214]) @=? (Y.decode $ pack [61,64])
    (Right $ pack [224]) @=? (Y.decode $ pack [61,74])
    (Right $ pack [227]) @=? (Y.decode $ pack [61,77])
    (Right $ pack [19]) @=? (Y.decode $ pack [61,125])

-- {{{1 tests & main
tests = [$(testGroupGenerator)]

main = defaultMain tests
