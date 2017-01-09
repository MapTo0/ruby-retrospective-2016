CELSIUS_COEFFICIENTS = {
  "C" => {
    "initial_value" => 0,
    "delta" => 1,
    "formula_to_celsius" => -> (degrees) { degrees },
    "celsius_to_unit" => -> (degrees) { degrees }
  },
  "F" => {
    "initial_value" => 32,
    "delta" => 1.8,
    "celsius_to_unit" => -> (degrees) { degrees * 1.8 + 32 },
    "formula_to_celsius" => -> (degrees) { (degrees - 32) / 1.8 }
  },
  "K" => {
    "initial_value" => 273.15,
    "delta" => 1,
    "celsius_to_unit" => -> (celsius) { celsius + 273.15 },
    "formula_to_celsius" => -> (degrees) { degrees - 273.15 }
  }
}

SUBSTANCE_MELTING_POINTS = {
  "water" => 0,
  "ethanol" => -114,
  "gold" => 1064,
  "silver" => 961.8,
  "copper" => 1085
}

SUBSTANCE_BOILING_POINTS = {
  "water" => 100,
  "ethanol" => 78.37,
  "gold" => 2700,
  "silver" => 2162,
  "copper" => 2567
}

def convert_between_temperature_units(degrees, convert_from_unit, convert_to_unit)
  celsius = CELSIUS_COEFFICIENTS[convert_from_unit]["formula_to_celsius"].call(degrees)
  CELSIUS_COEFFICIENTS[convert_to_unit]["celsius_to_unit"].call(celsius)
end

def melting_point_of_substance(substance, unit)
  convert_between_temperature_units(SUBSTANCE_MELTING_POINTS[substance], "C", unit)
end

def boiling_point_of_substance(substance, unit)
  convert_between_temperature_units(SUBSTANCE_BOILING_POINTS[substance], "C", unit)
end