require "kemal"
require "json"

require "../config/config"

require "./utils/*"


# Configurações a serem feitas antes de todas outras
before_all do |context|
  context.response.content_type = "application/json"
end

# Configuração inicial do get / 
get "/" do |context|
  {detail: "Multiverse Travels Booker", author: "Thays Azevedo", email: "thaysaparecida2015@gmail.com"}.to_json
end

# Rota para criar um Travel Plans
post "/travel_plans" do |context| 
  # Lógica para criar um Travel Plan pegando as informações do body e formatando
  ## as informações
  deserialize_body = TravelStops.from_json context.request.body.not_nil!
  
  begin
    travel_stops = deserialize_body.travel_stops
  
    travel_stops_json = travel_stops.to_json
    create_travel_plan = TravelPlans.create(travel_stops: travel_stops_json)

    halt context, status_code: 201, response: create_travel_plan.to_json(only: %w[id travel_stops])   

  rescue JSON::SerializableError
    context.response.status_code = 500
  end
end

# Rota para listar informações de todos Travel Plans
get "/travel_plans" do |context|
  travels = TravelPlans.all 
  
  # Formata as informações dos Travel Plans existentes, para formação 
  ## dos responses
  formatTravels = travels.to_json(only: %w[id travel_stops])

  # Caso Travels Plans seja vazio retorne a informação

  
  # Se existir travel plans, verifique a existência dos query
  ## query params
  optimize = context.params.query["optimize"]?  == "true"
  expand = context.params.query["expand"]?  == "true"
   
  # Se existir qualquer query param, para cada item de Travel Plans
  ## faça a requisição usando graphql para obter todas as informações necessárias 
  ### aos parâmetros
  if expand || optimize
    travelsJson = JSON.parse(formatTravels.to_s)

    sizeTravels = travelsJson.size
    
    # Para montagem se json response
    allResponses = [] of TravelPlanExpand

    countPlans = 0

    while  countPlans < sizeTravels
      correntPlan = travelsJson[countPlans]
      
      idTavelPlan = correntPlan["id"]
      idTavelPlan = idTavelPlan.to_s

      travelStops = correntPlan["travel_stops"]

      sizeTravelArray = travelStops.size
      responseGraphql = fetchRickAndMortyApiByGraphql(travelStops.to_json)

      locations = JSON.parse(responseGraphql.to_json)
      locations = locations["data"]["locationsByIds"]

      # Se optimize, pegue o array de response, que poder ser um array de inteiros,
      ## Exceto se exapand também for true o que retorna um array de travelStopsExpand
      if optimize
        # Chama função de pegar a popularidade de cada travel stop
        locationPopularity = getLocationPopularity(locations, sizeTravelArray)
        optimizeTravelStops = optimizeTravelStops(locations, locationPopularity, expand)

        optimizeResponse = {
          "id": idTavelPlan.to_i,
          "travel_stops": optimizeTravelStops
        }.to_json
        
        allResponses << TravelPlanExpand.from_json(optimizeResponse)    
      
      # Se existir o param expand sem o optimize, apenas pegue as informações
      ## de cada id no travel stops
      elsif expand || optimize==false
        expandTravelStops = manipulateExpandResponseById(locations, sizeTravelArray)
  
        expandResponse = {
          "id"=> idTavelPlan.to_i,
          "travel_stops" => expandTravelStops
        }.to_json

        allResponses << TravelPlanExpand.from_json(expandResponse)
        
      end      
      countPlans += 1
    end
    # Response para existência de params
    halt context, status_code: 200, response: allResponses.to_json    
  end
  # Response default
  halt context, status_code: 200, response: formatTravels
end

# Rota para listar informações de um Travel Plan
get "/travel_plans/:id" do |context|
  id : String = context.params.url["id"]

  travel = TravelPlans.find(id)

  # Caso não exista Travel Plan com o id requisitado
  if travel
    optimize = context.params.query["optimize"]?  == "true"
    expand = context.params.query["expand"]?  == "true"

    travelStops = travel.to_json(only: %w[travel_stops])

    travelArray = TravelStops.from_json travelStops
    travelStopsArray = travelArray.travel_stops

    sizeTravelArray = travelStopsArray.size
    
    # Se existir qualquer query param, faça a requisição usando graphql
    ## para obter todas as informações necessárias aos parâmetros
    if expand || optimize
      
      responseGraphql = fetchRickAndMortyApiByGraphql(travelStopsArray.to_json)

      locations = JSON.parse(responseGraphql.to_json)
      locations = locations["data"]["locationsByIds"]

      # Se optimize, pegue o array de response, que poder ser um array de inteiros,
      ## Exceto se exapand também for true o que retorna um array com informações dos
      ### travel_stops na ordem otimizada
      if optimize
        # Chama função de pegar a popularidade de cada travel stop
        locationPopularity = getLocationPopularity(locations, sizeTravelArray)
        optimizeTravelStops = optimizeTravelStops(locations, locationPopularity, expand)
      
        optmizeResponse = {
          "id": id.to_i,
          "travel_stops": optimizeTravelStops
        }.to_json
        
        halt context, status_code: 200, response: optmizeResponse
      end

      # Se existir o param expand, apenas pegue as informações
      ## de cada id no travel stops na ordenação default
      if expand
        expandTravelStops = manipulateExpandResponseById(locations, sizeTravelArray)
        
        expandResponse = {
          "id": id.to_i,
          "travel_stops": expandTravelStops
        }.to_json
        
        halt context, status_code: 200, response: expandResponse
      end
            
    else  
      defaultResponse = {
        "id": id.to_i,
        "travel_stops": travelStopsArray
      }
      # Response caso não exista os params como true
      halt context, status_code: 200, response: defaultResponse.to_json
    end 

  else
    # Response caso id requisitado não exista
    halt context, status_code: 404 
  end
  
end

# Rota para atualizar informações de um Travel Plans
put "/travel_plans/:id" do |context|
  id = context.params.url["id"]?

  travelPlanToUpdate = TravelPlans.find(id)
  
  # Caso não exista Travel Plan com o id a ser atualizado 
  if travelPlanToUpdate

    begin
      deserializeBody = TravelStops.from_json context.request.body.not_nil!
      newTravelStops = deserializeBody.travel_stops
      newTravelStopsJson = newTravelStops.to_json
      
      travelPlanToUpdate.update(travel_stops: newTravelStopsJson)

      halt context, status_code: 200, response: travelPlanToUpdate.to_json(only: %w[id travel_stops])
      # context.response.p! travelPlanToUpdate.to_json(only: %w[id travel_stops])
  
    rescue JSON::SerializableError
      context.response.status_code = 500
    end
    
  else
    halt context, status_code: 404 
  end
end

# Rota para deletado um Travel Plans
delete "/travel_plans/:id" do |context|
  id = context.params.url["id"]?

  travelToDelete = TravelPlans.find(id)
  
  # Caso não exista Travel Plan com o id a ser deletado
  if travelToDelete 
    travelToDelete.delete

    context.response.content_type = "application/json"
    context.response.status_code=204
  else
    halt context, status_code: 404 
  end  
end


# Formatando saída de erros 400, 404 e 500
# error 400 do |context|
#   context.response.content_type = "application/json"
#   {status: "error", message: "bad_request"}.to_json
# end

# error 404 do |context|
#   context.response.content_type = "application/json"
#   {status: "error", message: "TravelPlan not found"}.to_json
# end

# error 500 do |context|
#   context.response.content_type = "application/json"
#   {status: "error", message: "Bad....bad array to create. Try again :)"}.to_json
# end

Kemal.run