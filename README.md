# Projeto PRF 2025 — Preparação dos Dados


## Objetivo
Preparar os dados de acidentes da PRF 2025 para análise exploratória, Power BI e árvore de 
decisão explicável.


## Variável-alvo
`acidente_fatal = 1` quando `mortos >= 1`; caso contrário, `acidente_fatal = 0`.


## Bases geradas
- `dados_tratados\base_analitica_prf_2025.csv`: base completa para EDA e Power BI.
- `dados_tratados\base_modelavel_prf_2025.csv`: base para modelagem, sem data leakage.


## Observação metodológica
A base modelável exclui mortos, feridos, total_vitimas, indice_gravidade e variáveis diretamente 
derivadas do desfecho.

---

# Módulo 1: Fundamentos de Data Analytics e Preparação de Dados

Este módulo aborda desde os conceitos iniciais da metodologia CRISP-DM até a preparação prática de uma base de dados utilizando ferramentas essenciais de mercado (Excel, SQL e Python). Todo o fluxo é guiado pela **Formulação do Problema Binário: `acidente_fatal`**, utilizando a base real de dados da PRF (Polícia Rodoviária Federal) de 2025.

---
## Estrutura de Pastas e Organização do Projeto

Abaixo está a representação da árvore de diretórios do repositório, mapeando os conteúdos interativos, dados originais, scripts de tratamento e relatórios gerados ao longo das 4 aulas do módulo.

```text
.
├── README.md                                  # Documentação principal do projeto
│
├── _Modulo_1_Unidade_1/                      # Fundamentos de Data Analytics & CRISP-DM
│   ├── Aula_1_Analise_de_Dados/               # Conteúdo interativo e slides da aula
│   ├── Dados_PRF_2025/                        # Repositório de dados originais
│   │   ├── dados_prf_2025.csv                 # Arquivo bruto de acidentes da PRF
│   │   └── Dicionario_Dados.txt               # Documentação das variáveis (ArquivoTXT)
│   └── Atividades_Excel/                      # Primeiras explorações de planilhas
│
├── _Unidade_2_Excel/                        # Importação e Inspeção Inicial
│   ├── Aula_2_Analise_de_Dados/               # Conteúdo interativo de Excel aplicado
│   ├── ATIVIDADE_2/                           # Desafios práticos e gabaritos
│   │   ├── Tabelas_Dinamicas.xlsx             # Análises pivotadas
│   │   └── Graficos_Exploratorios.xlsx        # Visualizações iniciais de dados
│   └── ArquivoPDF/                            # Manuais e orientações da atividade
│
├── _Unidade_3_SQL_DuckDB_SQLite/            # Consultas Estruturadas & Banco Local
│   ├── Aula_3_Analise_de_Dados/               # Conteúdo interativo e ambiente SQL
│   └── scripts_sql/                           # Queries documentadas (.sql)
│       ├── 01_importacao_e_select.sql         # Leitura do CSV e filtros WHERE
│       ├── 02_agregacoes_e_indicadores.sql    # Métricas globais com GROUP BY
│       ├── 03_criacao_alvo_binario.sql        # Regra de negócio CASE WHEN (acidente_fatal)
│       ├── 04_rankings_analiticos.sql         # Agrupamentos por UF, BR e Município
│       └── 05_consultas_temporais.sql         # Filtros de data e evolução cronológica
│
└── _Unidade_4_Python_Pandas/                # Pipeline de Preparação & Engenharia
    ├── Aula_4_Analise_de_Dados/               # Conteúdo interativo e notebooks da aula
    ├── notebooks/                             # Jupyter Notebooks organizados por etapa
    │   ├── 01_inspecao_e_tipos.ipynb          # Leitura, dicionário e tratamento de datas/horas
    │   ├── 02_limpeza_e_higienizacao.ipynb    # Padronização de texto, nulos e duplicidades
    │   ├── 03_feature_engineering.ipynb       # Criação de variáveis temporais, gravidade e local
    │   └── 04_preparacao_e_leakage.ipynb      # Divisão de bases e prevenção de Data Leakage
    └── bases_exportadas/                      # Outputs gerados para integração
        ├── base_analitica_dashboard.csv       # Base completa para Power BI / Looker
        └── base_modelavel.csv                 # Base limpa e segura contra vazamento para ML
```

---

### 📝 Guia de Navegação Rápida

*   **Para validar as regras de negócio do problema binário:** Acesse a pasta `🗄️_Unidade_3_SQL_DuckDB_SQLite/scripts_sql/` e consulte o arquivo de criação do alvo.
*   **Para reproduzir o pipeline de limpeza de dados:** Execute sequencialmente os notebooks contidos na pasta `🐍_Unidade_4_Python_Pandas/notebooks/`.
*   **Para conectar ferramentas de BI:** Os dados finais tratados estão disponíveis em `bases_exportadas/`.
## 📈 Resumo do Módulo

| Unidade | Ferramenta Principal | Foco Prático |
| :--- | :--- | :--- |
| **Unidade 1** | Conceitual & Negócio | Formulação do problema binário (`acidente_fatal`) usando CRISP-DM. |
| **Unidade 2** | Microsoft Excel | Importação de arquivos CSV, inspeção visual, tabelas dinâmicas e gráficos. |
| **Unidade 3** | SQL (DuckDB / SQLite) | Consultas analíticas, agregações, filtros temporais e criação da variável alvo. |
| **Unidade 4** | Python (`pandas`) | Limpeza de dados, engajamento de features e prevenção de *Data Leakage*. |

