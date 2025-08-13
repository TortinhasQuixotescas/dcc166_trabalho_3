= Metodologia <methodology>

A modelagem analítica é um processo fundamental no campo da ciência de dados e da análise de negócios, que consiste na criação de representações matemáticas e lógicas de sistemas, processos ou problemas do mundo real.
Seu objetivo principal é compreender as relações entre diferentes variáveis e prever resultados futuros com base em dados históricos e em um conjunto de premissas definidas @arbex:2025:data_science_decision_support.

Nesse sentido, os @sad:pl são sistemas computacionais projetados para auxiliar gestores de organizações a tomar decisões complexas.
Eles têm o propósito de reunir um conjunto de informações relevantes, provenientes de fontes não necessariamente estruturadas, e apresentá-las com um caráter informativo.
O método faz parte da modelagem analítica, transformando dados brutos em informações, sintetizadas em relatórios e projeções @gillis:2024:decision_support_system.

Os dados necessários para a análise foram obtidos do Portal de Dados Abertos do Governo Federal do Brasil, por meio do dataset acerca da relação anual de ingressantes no @prouni @dados_gov_br:2025:prouni.
Este dataset está disponível em formato @csv, apresentando um documento para cada ano entre 2005 e 2020.

Cada registro contém as seguintes informações:
ano da concessão da bolsa;
código do e-MEC da @ies que concedeu a bolsa;
nome da @ies;
tipo da bolsa;
modalidade de ensino;
nome do curso;
turno do curso;
CPF do beneficiário;
sexo do beneficiário;
raça ou cor;
data de nascimento do beneficiário;
indicação se o beneficiário é portador de deficiência;
região geográfica de residência do beneficiário;
UF de residência do beneficiário;
município de residência do beneficiário.

Extraímos dados no formato @ods do portal @sidra referentes aos censos demográficos de 2010 e 2022.
Por meio da
#emph[Tabela 9605: População residente, por cor ou raça, nos Censos Demográficos]
#cite(<ibge:2025:populacao_por_cor>),
selecionamos os municípios caracterizados como metropolitanos
#footnote[
  Definimos como municípios metropolitanos aqueles que são capitais de unidades federativas ou que estejam em região metropolitana, concentração urbana ou arranjo populacional em que se encontra capital de unidade federativa.
],
sobre os quais se selecionou a população residente por cor ou raça.
Em seguida, fizemos a mesma busca para todos os municípios.
Então, selecionamos da
#emph[Tabela 9606: População residente, por cor ou raça, segundo o sexo e a idade]
#cite(
  <ibge:2025:populacao_por_idade>,
)
a população residente dentro do grupo etário de 18 a 24 anos e a população total.

A fim de organizar os dados, desenvolvemos um diagrama de classes utilizando a ferramenta PlantUML @plantuml:2025:plantuml, que representa as relações entre as entidades identificadas.
Este modelo, apresentado na @class_diagram, define as entidades a seguir.
(1) `City`: representa um município, guardando seu nome, unidade federativa e a informação de se é metropolitano ou não.
(2) `Census`: guarda as informações de interesse coletadas pelo censo demográfico de determinado ano para um município.
(3) `Concession`: representa a concessão de uma bolsa do ProUni, contendo informações sobre a cor ou raça do beneficiário, sua idade, e uma relação com a cidade onde reside.
(4) `Course`: representa um curso oferecido por uma @ies.
(5) `Institution`: representa uma @ies, contendo seu nome e o código do e-MEC.

#figure(
  image("./images/class_diagram.svg", width: 100%),
  caption: [Diagrama de classes UML representando a estrutura de dados.\ Fonte: Elaborado pelos autores (2025).
  ],
)<class_diagram>

// Com o modelo de dados definido, foi utilizado o sistema gerenciador de banco de dados SQLite @sqlite:2025:sqlite para criar a estrutura lógica do banco.
// As tabelas foram criadas de acordo com o diagrama de classes apresentado por meio da linguagem SQL, com o apoio da ferramenta de @ia DeepSeek @deepseek:2025:deepseek para tradução da modelagem UML para SQL.

// Em seguida, os autores criaram por meio da mesma ferramenta de @ia um conjunto de dados sintéticos referentes a receitas, insumos e seus custos, descritos em comandos de inserção de dados SQL.
// Tais comandos podem ser acessados por meio do repositório público do projeto @tortinhas_quixotescas:2025:repository_dcc166_atv2.

// As três receitas escolhidas, quais sejam pão francês, brigadeiro e bolo de milho verde, são baseadas em receitas reais e foram selecionadas por utilizarem poucos ingredientes, facilitando a análise, com o compartilhamento de alguns insumos, como manteiga e açúcar, entre si.
// Os valores atribuídos aos preços dos insumos foram escolhidos de maneira arbitrária, uma vez que estes podem variar drasticamente por fatores como região e fornecedor.
// Contudo, buscamos representar preços praticados no mercado brasileiro, de forma que foi mantida uma relação de proporção lógica entre os produtos.
// Por exemplo, o leite condensado possui um custo superior ao da água.

// A seleção das receitas também considerou a variação de volume de armazenamento de seus ingredientes.
// Esta pode ser uma informação relevante para a tomada de decisão, pois ingredientes de pequeno volume que impactam drasticamente o lucro podem e devem ser comprados em quantidades maiores para mitigar riscos de desabastecimento ou aumento de preço.
// Adicionalmente, buscamos analisar a hipótese de que o estabelecimento deve procurar diversificar seu portfólio de produtos com receitas que não dependam excessivamente dos mesmos ingredientes, distribuindo assim o risco associado à volatilidade de preços.

// Após a criação do banco de dados e dos dados sintéticos, os autores substituíram o sistema de banco de dados SQLite pelo PostgreSQL @postgresql:2025:postgresql, que foi hospedado em um servidor remoto, permitindo o acesso simultâneo por múltiplos usuários e pela ferramenta de visualização de dados.
// Então, a ferramenta de @ia DeepSeek foi novamente utilizada para traduzir os comandos SQL de um dialeto para outro.
// Em seguida, os dados foram devidamente inseridos.

// A fim de criar o dashboard para visualização dos resultados, foi utilizada a ferramenta de @bi de código aberto Apache Superset @apache_superset:2025:apache_superset.
// Para fins de apresentação e trabalho colaborativo, foi empregada a plataforma Preset.io @preset:2025:preset, uma solução baseada em nuvem que hospeda o Apache Superset, facilitando o acesso remoto e o compartilhamento dos dashboards.
// Assim, o Preset.io permitiu a conexão direta com o banco de dados PostgreSQL e a criação de gráficos interativos.

// Os autores elaboraram, com apoio da ferramenta DeepSeek, consultas SQL para extrair dados relevantes do banco, como o custo total de produção de cada receita, o lucro e a margem de lucro, considerando seus insumos e seus custos de venda.
// Cada consulta foi transformada em um dataset virtual no Superset.
// Assim, foi possível criar gráficos que utilizem esses datasets como fonte de dados.
// Os gráficos, por sua vez, foram organizados em um dashboard composto de cinco seções: (1) informações gerais em tabelas, (2) análise de risco dos insumos considerando o uso médio em todas as receitas, e (3, 4, 5) análise de impacto de cada insumo nas três receitas selecionadas.

// O caráter da análise de sensibilidade foi implementado por meio da simulação de cenários de aumento de custo de cada insumo nas proporções de +5%, +10% e +15%, codificados nas consultas SQL utilizadas para gerar os datasets.
// Assim, para cada receita, foi possível observar o lucro resultante de uma porção caso se variasse cada insumo em cada uma das proporções.
// Também foi extraído o #emph[delta] do lucro estimado em relação ao lucro original, o que diretamente indica o impacto do aumento de custo do insumo no lucro da receita.
