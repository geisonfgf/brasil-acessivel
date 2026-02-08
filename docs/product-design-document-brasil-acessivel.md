# Product Design Document (PDD) - Brasil Acessivel

Data: 2026-02-08  
Status: Draft v1  
Produto: Brasil Acessivel (Web + Mobile-first/PWA)  

## 1) Contexto

O prototipo academico do Brasil Acessivel validou o problema central: pessoas com mobilidade reduzida precisam descobrir, com antecedencia, se um local e realmente acessivel.  
O estudo original descreve funcionalidades base importantes:

- busca georreferenciada de locais acessiveis;
- exibicao em mapa;
- classificacao por nivel de acessibilidade;
- filtros por perfil de deficiencia;
- assistente com heuristica de proximidade (ate 2500 m) e melhor acessibilidade;
- possibilidade de reportar atributos do local.

Como benchmark de produto, o Wheelmap mostra padroes valiosos:

- modelo crowdsourced com base OpenStreetMap (OSM);
- classificacao simples e compreensivel (acessivel, parcialmente acessivel, nao acessivel, desconhecido);
- contribuicao de dados diretamente no mapa;
- foco em atualizacao frequente de dados.

## 2) Problema

Usuarios com mobilidade reduzida ainda enfrentam incerteza alta ao escolher restaurantes, hoteis, servicos e equipamentos urbanos.  
Essa incerteza gera risco real (deslocamento inutil, constrangimento, inseguranca e perda de autonomia).

## 3) Visao do Produto

Ser o mapa mais confiavel do Brasil para decisao de deslocamento acessivel, combinando dados abertos, validacao comunitaria e filtros personalizados por necessidade de mobilidade.

## 4) Objetivos e Nao Objetivos

## Objetivos (12 meses)

- reduzir incerteza antes do deslocamento;
- aumentar cobertura de locais com dados de acessibilidade util;
- oferecer experiencia simples para consulta e contribuicao de dados;
- padronizar dados para interoperabilidade (A11yJSON/OSM-friendly).

## Nao objetivos (fase inicial)

- roteamento acessivel porta-a-porta completo;
- auditoria legal/certificacao formal de acessibilidade predial;
- cobranca direta de usuarios finais no MVP.

## 5) Personas Prioritarias

## Persona 1: Usuario cadeirante frequente

- precisa decidir rapido onde ir com menor risco;
- prioriza entrada sem degrau, banheiro acessivel e rota interna.

## Persona 2: Familiar/cuidador

- pesquisa locais para terceiros (viagem, saude, lazer);
- valoriza comparacao entre opcoes e evidencias confiaveis.

## Persona 3: Colaborador comunitario

- quer adicionar/corrigir dados locais;
- precisa de fluxo curto e feedback claro do impacto da contribuicao.

## 6) Proposta de Valor

- para usuarios: "descubra opcoes acessiveis proximas com nivel de confianca";
- para comunidade: "contribua em segundos e melhore a cidade para todos";
- para parceiros publicos/privados: "dados estruturados para planejamento e melhoria."

## 7) Principios de Design de Produto

- simplicidade radical: poucos estados, linguagem clara;
- confianca explicita: exibir fonte, data e nivel de confianca do dado;
- acessibilidade por padrao: UX e UI seguindo WCAG 2.2 AA;
- colaboracao guiada: contribuir deve ser tao facil quanto consultar;
- interoperabilidade: dados exportaveis e compativeis com ecossistema aberto.

## 8) Escopo Funcional

## 8.1 MVP (Fase 1)

1. Mapa principal com geolocalizacao do usuario.
2. Busca por endereco/regiao.
3. Exibicao de locais com estado de acessibilidade:
   - acessivel;
   - parcialmente acessivel;
   - nao acessivel;
   - sem dados.
4. Filtros por:
   - categoria de local (restaurante, hotel, servicos essenciais);
   - distancia;
   - nivel minimo de acessibilidade.
5. Assistente de acessibilidade:
   - aplica filtro inteligente padrao;
   - prioridade para locais proximos e com melhor avaliacao.
6. Detalhe do local com atributos objetivos:
   - entrada;
   - circulacao interna;
   - banheiro;
   - vaga/estacionamento;
   - elevador/rampa (quando aplicavel).
7. Contribuicao comunitaria:
   - marcar status;
   - enviar atualizacao de atributos;
   - anexar evidencia (foto opcional, quando permitido).
8. Conta opcional:
   - consulta anonima liberada;
   - edicao persistente com login.
9. Historico minimo de alteracoes por local (quem, quando, o que mudou).
10. Web responsivo com qualidade mobile e PWA.

## 8.2 Fase 2

1. Confianca por reputacao de contribuidores.
2. Moderacao assistida (detecao de conflito/spam).
3. Colecoes de locais acessiveis (listas para viagem/rotina).
4. Camada de "validado por parceiro" (ONGs/prefeituras).

## 8.3 Fase 3

1. Rotas acessiveis (quando base viaria suportar).
2. Recomendacoes personalizadas por perfil de mobilidade.
3. API publica para ecossistema gov/terceiro setor.

## 9) Requisitos Funcionais (RF)

- RF-01: O sistema deve localizar o usuario (com consentimento) e centralizar o mapa.
- RF-02: O sistema deve buscar locais por coordenada e por texto.
- RF-03: O sistema deve classificar e exibir acessibilidade em estados padronizados.
- RF-04: O sistema deve permitir filtrar por categoria, distancia e nivel minimo.
- RF-05: O sistema deve disponibilizar assistente de acessibilidade de um toque.
- RF-06: O sistema deve exibir detalhes e data da ultima atualizacao do local.
- RF-07: O sistema deve permitir contribuicoes de novos dados e correcao de dados.
- RF-08: O sistema deve armazenar trilha de auditoria de alteracoes.
- RF-09: O sistema deve suportar exportacao/importacao em formato estruturado compativel.

## 10) Requisitos Nao Funcionais (RNF)

- RNF-01 (Acessibilidade): conformidade WCAG 2.2 AA no produto digital.
- RNF-02 (Performance): mapa interativo em ate 2,5s p95 em 4G para area urbana media.
- RNF-03 (Disponibilidade): 99,5% mensal no MVP.
- RNF-04 (Privacidade): aderencia a LGPD (minimizacao de dados pessoais, consentimento, base legal).
- RNF-05 (Seguranca): autenticacao segura, rate limiting e trilha de auditoria.
- RNF-06 (Qualidade de dados): cada registro deve ter fonte e timestamp.
- RNF-07 (Observabilidade): logs, metricas e alertas de erros de busca/contribuicao.

## 11) Modelo de Dados (alto nivel)

Entidades principais:

- Place: id, nome, categoria, coordenadas, endereco.
- AccessibilityAssessment: status geral, subatributos (entrada, banheiro, etc.), fonte, timestamp.
- Contributor: id, tipo (anonimo/autenticado/parceiro), reputacao.
- Evidence: foto/url/comentario curto, data.
- ChangeLog: diff de alteracoes, autor, data, motivo.

Padroes e interoperabilidade:

- estrutura interna com compatibilidade para A11yJSON;
- mapeamento de tags OSM relevantes (ex.: `wheelchair`, `toilets:wheelchair`) para atributos internos;
- versao de esquema para evolucao sem quebrar integracoes.

## 12) Regras de Negocio de Classificacao

Modelo inicial recomendado (simples e explicavel):

- Estado principal:
  - `accessible`;
  - `partially_accessible`;
  - `not_accessible`;
  - `unknown`.
- Subscores por atributo (entrada, banheiro, circulacao, elevador/rampa).
- Score final (0-100) apenas para ordenacao interna.
- Estado visual deriva de regras deterministicas, nao de "caixa preta".

Exemplo de diretriz:

- `accessible`: entrada sem degrau relevante e acesso interno viavel;
- `partially_accessible`: barreiras pontuais, mas uso ainda possivel em parte;
- `not_accessible`: barreira impeditiva principal;
- `unknown`: dados insuficientes ou desatualizados.

## 13) UX e Fluxos-Chave

Fluxos prioritarios:

1. Descobrir local agora:
   - abrir app -> permitir localizacao -> aplicar assistente -> escolher local.
2. Planejar viagem:
   - buscar cidade/endereco -> filtrar hotel/restaurante -> comparar opcoes.
3. Contribuir dado:
   - abrir detalhe -> editar status/atributos -> enviar -> ver confirmacao.

Pontos de UX obrigatorios:

- legenda de estados sempre visivel;
- informacao de "ultimo update" em destaque;
- CTA de contribuicao no detalhe do local;
- empty states com orientacao objetiva.

## 14) Arquitetura de Solucao (proposta)

- Frontend Web/PWA (mapa, busca, filtros, detalhe, contribuicao).
- API Backend (consulta, scoring, contribuicao, auditoria).
- Data Layer:
  - ingestao de dados abertos (OSM e/ou outras fontes);
  - armazenamento principal de lugares + historico;
  - adaptador de exportacao/importacao A11yJSON.
- Servicos auxiliares:
  - geocoding/reverse geocoding;
  - fila de processamento para moderacao e reconciliacao de dados.

## 15) Confianca e Qualidade de Dados

Sinalizadores de confianca no frontend:

- fonte dos dados (comunidade/parceiro/base aberta);
- recencia da informacao;
- quantidade de confirmacoes independentes;
- conflito de dados (quando houver divergencia recente).

Mecanismos de qualidade:

- deduplicacao por proximidade + nome;
- bloqueio de spam e limite de edicao por janela de tempo;
- fila de revisao para mudancas de alto impacto.

## 16) Metricas de Produto

North Star Metric:

- percentual de buscas que terminam em "local escolhido com confianca".

Metricas de apoio:

- taxa de sucesso da busca (resultado util em ate 3 interacoes);
- tempo ate primeira opcao confiavel;
- cobertura de locais com status nao-desconhecido;
- contribuicoes validas por usuario ativo;
- percentual de locais atualizados nos ultimos 12 meses;
- NPS/CSAT de usuarios com mobilidade reduzida.

## 17) Roadmap (sugestao)

Fase 0 (2-4 semanas):

- arquitetura, schema de dados, design system acessivel, metricas.

Fase 1 MVP (8-12 semanas):

- mapa + busca + filtros + assistente + detalhe + contribuicao basica + auditoria.

Fase 2 (6-8 semanas):

- confianca/reputacao + moderacao + parceiros pilotos.

Fase 3 (continuo):

- rotas acessiveis + API publica + expansao nacional por cidade.

## 18) Riscos e Mitigacoes

- Risco: baixa qualidade dos dados iniciais.
  - Mitigacao: exibir confianca, incentivar confirmacao comunitaria e parceiros locais.
- Risco: cobertura desigual entre cidades.
  - Mitigacao: campanhas regionais e onboarding de multiplicadores.
- Risco: custos de mapas/geocoding em escala.
  - Mitigacao: estrategia hibrida com stack open e caches.
- Risco: acessibilidade do proprio app ficar abaixo do esperado.
  - Mitigacao: testes continuos com usuarios PCD + auditorias WCAG.
- Risco: incerteza de integracao com fontes externas.
  - Mitigacao: arquitetura de conectores desacoplados e fallback de dataset.

## 19) Decisoes de Produto para iniciar ja

1. Adotar classificacao em 4 estados (simples para usuario) + score interno.
2. Priorizar consulta anonima e contribuicao com login opcional no MVP.
3. Implementar indicador de confianca desde o primeiro release.
4. Manter interoperabilidade com A11yJSON e mapeamento OSM desde o schema inicial.
5. Validar UX com usuarios cadeirantes em ciclos quinzenais.

## 20) Referencias utilizadas

- Documento base do projeto: `/Users/geisonfgf/Projects/saas/brasil-acessivel/docs/bracessivel.txt`
- Wheelmap (FAQ): https://news.wheelmap.org/en/faq/
- Wheelmap (About): https://news.wheelmap.org/en/about/
- Wheelmap (atualizacoes de plataforma): https://news.wheelmap.org/en/new-wheelmap-test/
- Wheelmap no OSM Wiki (tags e estados): https://wiki.openstreetmap.org/wiki/Wheelmap
- A11yJSON (descricao do padrao): https://a11yjson.org/

## 21) Itens em aberto para refinamento

- decidir stack oficial de mapas e geocoding para escala nacional;
- definir politica de moderacao (centralizada vs comunitaria) e SLA;
- priorizar segmentos iniciais por cidade (piloto: Porto Alegre + Sao Paulo);
- definir metas numericas de cobertura e confianca por trimestre.
