# Atividade AWS & Docker CompassUOL

## Requisitos

+ Instalação e configuração do DOCKER ou CONTAINERD no host EC2
    + Ponto adicional para o trabalho utilizar a instalação via script de Start Instance (user_data.sh)
+ Efetuar Deploy de uma aplicação Wordpress com:
    + Container de aplicação
    + RDS database Mysql
+ configuração do serviço de Load Balancer AWS para a aplicação Wordpress

### Topologia do projeto
<img src="images/arquitetura-atividade.png">

### Pontos de atenção

+ Não utilizar ip público para saída do serviços WP (Evitem publicar o serviço WP via IP público)
+ Sugestão para o tráfego de internet sair pelo LB (Load Balancer Classic)
+ Pastas públicas e estáticos do wordpress sugestão de utilizar o EFS (Elastic File Sistem)
+ Fica a critério de cada integrante usar Dockerfile ou Dockercompose
+ Necessário demonstrar a aplicação wordpress funcionando (tela de login)
+ Aplicação Wordpress precisa estar rodando na porta 80 ou 8080
+ Utilizar repositório git para versionamento
+ Criar documentação

## Parte Prática

### 1 - Criando a VPC
O primeiro passo será criar uma VPC para este projeto. Essa VPC terá dois pares de subnets. Cada par será constituído por uma subnet privada e outra pública, e cada par estará em uma AZ diferente.

A princípio, a configuração inicial da VPC será essa:

<img src="images/vpc01.png">

Um NAT Gateway será adicionado com o propósito de prover conexão com a internet. Para criar, basta nevagar até `NAT Gateways`

Para prover conexão para uma sub-rede privada, o NAT Gateway precisará ser anexado a uma sub-rede pública:

<img src="images/nat-gateway.png">

Após a criação do NAT Gateway, foi necessário alterar as rotas. Naveguei até `Route Tables`, selecionei cada uma das sub-nets privadas, adicionei uma rota para `0.0.0.0/0` com um target no `Nat Gateway`, e selecionei o NAT Gateway criado.

<img src="images/route-tables.png">


A configuração final da VPC ficou assim:

<img src="images/vpc02.png">

### 2 - Criando os Security Groups
Criando as regras para os SGs. Basta navegar para EC2 e selecionar `Security Groups`

#### SG-LB
|Type |Protocol |Port Range|Source    |
|-----|---------|----------|----------|
|HTTP |TCP      |80        |0.0.0.0/0 |


#### SG-EC2
|Type |Protocol |Port Range|Source    |
|-----|---------|----------|----------|
|HTTP |TCP      |80        |SG-LB     |
|SSH  |TCP      |22        |0.0.0.0/0 |

#### SG-EFS
|Type |Protocol |Port Range|Source    |
|-----|---------|----------|----------|
|FNS  |TCP      |2049      |0.0.0.0/0 |

#### SG-RDS
|Type          |Protocol |Port Range|Source    |
|--------------|---------|----------|----------|
|MYSQL/Aurora  |TCP      |3306      |0.0.0.0/0 |

### 3 - Criação do EFS
Utilizei o EFS para compartilhar diretórios do container do Wordpress.

Para criar um EFS, cliquei em `Create files system` preenchi os campos de `nome`, `VPC` e, em seguida cliquei em `customize`.

<img src="images/efs01.png">

A primeira parte foi deixada como padrão, a segunda apenas alterei os `Security groups` para o `SG-EFS`, nas outras partes eu também deixei como padrão.

<img src="images/efs02.png">