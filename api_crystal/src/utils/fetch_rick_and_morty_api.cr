def fetchRickAndMortyApiByGraphql(travelArray)
  
  graphqlQuery="{locationsByIds(ids:#{travelArray}){id,name,type,dimension,residents{episode{id}}}}"

  url = "https://rickandmortyapi.com/graphql?query=#{graphqlQuery}" 

  getGraphql = HTTP::Client.get(url)

  if getGraphql.status_code == 200
    responseGraphql = JSON.parse(getGraphql.body.to_s)
       
    return responseGraphql
  end
end