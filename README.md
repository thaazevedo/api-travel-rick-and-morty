# code-challenge

Este projeto consiste em uma API de planejamento de Viagens pelos planetas e dimensões
do universo de Rick and Morty. Como parte de sua estrutura a API TRAVEL PLANS, utiliza
as seguintes tecnologias:

- informações da [API](https://rickandmortyapi.com) de Rick and Morty; 
- a linguagem [Crystal](https://crystal-lang.org/reference/1.8/index.html); 
- o framework [Kemal](https://kemalcr.com/guide/); 
- o ORM [Jennifer](https://imdrasil.github.io/jennifer.cr/docs/getting_started).

## Informações Iniciais
As informações de um Travel Plan inclui:
- O ID do plano de viagem;
- Um array de informações sobre as paradas (localizações/planetas) do universo de 
  Rick and Morty, retiradas da API base;

### Recursos API Travel Plans
A API é utilizada para criar, visualizar e excluir planos de viagens:
1. Criando um plano: 
  - POST endpoint `/travel_plans`
  - Deve receber no corpo da requisição um Array de Ids das locatizações
  existentes na [API](https://rickandmortyapi.com/documentation/#get-all-locations)
  base;

2. Visualizando todos os planos de viagem:
  - GET endpoint `/travel_plans`
  - Aceita parâmetros: optimize e expand - definidos por padrão como falso;
  - Se não receber nenhum parâmetro retorna, normalmente todos os planos de viagem;
  - Se receber optimize como true, retorna para cada plano de viagem, as paradas (travel_stops)
    reordenados de forma e otimizar os saltos interdimensionais;
  - Se receber expand como true, retorna as seguintes informações de cada item do array 
    de travel_stops: nome da localização, tipo e a dimensão localizada.

3. Visualizando de um plano de viagem:
  - GET endpoint `/travel_plans/:id`
  - Aceita parâmetros: optimize e expand - definidos por padrão como falso;
  - Se não receber nenhum parâmetro retorna, normalmente todos os planos de viagem;
  - Se receber optimize como true, retorna o plano de viagem com as paradas (travel_stops)
    reordenados de forma e otimizar os saltos interdimensionais;
  - Se receber expand como true, retorna as seguintes informações de cada item do array 
    de travel_stops: nome da localização, tipo e a dimensão localizada.

4. Atualização de um plano de viagem existente:
  - PUT endpoint `/travel_plans/:id`
  - Deve receber no corpo da requisição um Array de Ids das locatizações
  existentes na [API](https://rickandmortyapi.com/documentation/#get-all-locations)
  base;
  - E atualiza o plano requisitado com o Array recebido;

5. Deleta um plano de viagem existente:
  - DELETE `/travel_plans/:id`
  - Apaga um plano de viagem e retorna status 204
  
## Contributing

1. Fork it (<https://github.com/your-github-user/code-challenge/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [thaazevedo](https://github.com/your-github-user) - creator and maintainer
