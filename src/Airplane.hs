module Airplane where

data Kilograms
data Pounds
data Fuel a = Fuel Double

loadFuel :: Fuel Kilograms -> IO ()
loadFuel (Fuel kilos) = undefined

conv :: Fuel Pounds -> Fuel Kilograms
conv (Fuel p) = Fuel (p / 2.2)

initFuel :: Fuel Pounds
initFuel = Fuel 55 :: Fuel Pounds

-- Will not compile
-- mistake :: IO ()
-- mistake = loadFuel initFuel