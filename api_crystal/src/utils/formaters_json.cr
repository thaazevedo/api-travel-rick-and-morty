# Classes para realizer a serialização ou a desserialização de um json
## utilizada para tratamento da informação recebida pelo body de uma requisição

class TravelStops
  include JSON::Serializable
  property travel_stops : Array(Int32)

end

class TravelPlanExpand
  include JSON::Serializable
  property id : Int32
  property travel_stops : Array(TravelStopsExpand) | Array(Int32)
  
end

class TravelStopsExpand
  include JSON::Serializable
  property id : Int32
  property name : String = ""
  property type : String = ""
  property dimension : String = ""

end

class PopularityLocation
  include JSON::Serializable
  property id : Int32 = 0
  property name : String = ""
  property type : String = ""
  property dimension : String = ""
  property popularity : Int32 = 0
end