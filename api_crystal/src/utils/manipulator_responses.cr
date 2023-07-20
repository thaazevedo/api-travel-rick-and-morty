require "./formaters_json"
# Funções responsáveis por realizar o tratamento das informações a
## serem enviadas nos responses expand e optmize

# Função que retorna as informações dos ids de um Plan Stop
def manipulateExpandResponseById(locations : JSON::Any, sizeTravelArray : Int32)
  expandTravelStops = [] of TravelStopsExpand
  
  countPlanTravelStops = 0
  
  # Para cada id no plan stops, formate as infomações necessárias
  ## ao retorno expand
  while countPlanTravelStops < sizeTravelArray

    location = locations[countPlanTravelStops]
  
    idLocationString = location["id"].to_s
    idLocationInt = idLocationString.to_i

    name = location["name"].to_s
    type = location["type"].to_s
    dimension = location["dimension"].to_s

    formatedLocation = {
      "id" => idLocationInt,
      "name" => name,
      "type" => type,
      "dimension" => dimension
    }.to_json

    expandTravelStops << TravelStopsExpand.from_json(formatedLocation)
   
    countPlanTravelStops += 1
  end

  return expandTravelStops
  
end

# Função para pegar informações sobre a popularidade dos travel_stops
def getLocationPopularity(locations : JSON::Any, sizeTravelArray : Int32)
  # Se o param optimize for true, é necessário obter as informações
  ## para cálculo de popularidade, tanto das locations quando das dimensions
  locationPopularity = [] of PopularityLocation

  countPlanTravelStops = 0
  
  while countPlanTravelStops < sizeTravelArray

    location = locations[countPlanTravelStops]

    # Formatanto informações tanto para cálculo de popularidade
    ## de uma dimensão quanto para casos de expand==true
    idLocationString = location["id"].to_s
    idLocationInt = idLocationString.to_i

    name = location["name"].to_s
    type = location["type"].to_s
    dimension = location["dimension"].to_s

    countResidents = 0
    residents = location["residents"]

    residentsJson = JSON.parse(residents.to_json)
    sizeResidents = residentsJson.size
    
    popularity = 0

    # A popularidade de um travel stops é calculada realizando a soma da quantidade
    ## de episódios em que cada um de seus residentes apareceu
    while countResidents < sizeResidents
      resident=residents[countResidents]
      
      episodesByResident = resident["episode"]
      episodesByResidentJson = JSON.parse(episodesByResident.to_json)
      totalEpisodesByResident = episodesByResidentJson.size

      popularity = popularity + totalEpisodesByResident
      countResidents += 1
    end

    formatedLocation = {
      "id" => idLocationInt,
      "name" => name,
      "type" => type,
      "dimension" => dimension,
      "popularity" => popularity
    }.to_json

    locationPopularity << PopularityLocation.from_json(formatedLocation)

    countPlanTravelStops += 1
  end

  return locationPopularity  
end

# Função que otimiza os travel_stops 
def optimizeTravelStops(locations : JSON::Any, locationPopularity : Array, expand : Bool)

  # Agrupamento das locations segundo a dimensão, para cálculo
  ## da popularidade por dimensão
  dimensions = locationPopularity.group_by { |location| location.dimension }

  # Cálculo da popularidade de uma dimensão é correnpondente a média
  ## da popularidade de cada localização da fimensão presente no travel_stops
  dimensionPopularities = dimensions.map do |dimension, locations|
    total_popularity = locations.sum { |location| location.popularity }
    averagePopularity = total_popularity / locations.size
    { dimension: dimension, averagePopularity: averagePopularity }
  end

  # Para montar um travel_stops otimizado é necessário realizar
  ## a ordenação das dimensões com base na média de popularidade 
  ### e ordem alfabética
  sorted_dimensions = dimensionPopularities.sort do |a, b|
    if a[:averagePopularity] == b[:averagePopularity]
      a[:dimension] <=> b[:dimension]
    else
      a[:averagePopularity] <=> b[:averagePopularity]
    end
  end

  # Após ordernar as dimensões, é necessário realizar a ordenação 
  ## de travel_stops dentro de uma mesma dimensão, com base na popularidade 
  ### e ordem alfabética e caso exista expand, já altere a formatação do retorno
  if expand 
    sorted_locations = sorted_dimensions.flat_map do |dimension_info|
      dimension = dimension_info[:dimension]
      locations = dimensions[dimension].sort do |a, b|
        if a.popularity == b.popularity
          a.name <=> b.name
        else
          a.popularity <=> b.popularity
        end
      end
      locations.map do |location|
        {
        "id" => location.id,
        "name" => location.name,
        "type" => location.type,
        "dimension" => location.dimension
        }
      end
    end 
    
  # Se não, apenas retorno o array com os ids dos travel stops
  elsif
    sorted_locations = sorted_dimensions.flat_map do |dimension_info|
      dimension = dimension_info[:dimension]
      locations = dimensions[dimension].sort do |a, b|
        if a.popularity == b.popularity
          a.name <=> b.name
        else
          a.popularity <=> b.popularity
        end
      end
      locations.map { |location| location.id }
    end
  end

  return sorted_locations
end