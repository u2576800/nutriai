// ============================================================
// Typst Academic Report — CN6000 Final Year Project
// Personalised Nutrition Recommendations Using XAI and
// Gut-Microbiome Data
// ============================================================

// ── Global page & typography setup ──────────────────────────
#set page(
  paper: "a4",
  margin: (top: 2.5cm, bottom: 2.5cm, left: 2.5cm, right: 2.5cm),
  number-align: center,
)

#set text(
  font: "Times New Roman",
  size: 12pt,
  lang: "en",
  region: "GB",
)

#set par(
  justify: true,
  leading: 0.65em,
  first-line-indent: 0pt,
  spacing: 0.65em,
)

#set heading(numbering: none)

// Heading styles
#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  v(0.8em)
  text(size: 18pt, weight: "bold")[#it.body]
  v(0.5em)
}

#show heading.where(level: 2): it => {
  v(0.6em)
  text(size: 14pt, weight: "bold")[#it.body]
  v(0.3em)
}

#show heading.where(level: 3): it => {
  v(0.5em)
  text(size: 12pt, weight: "bold", style: "italic")[#it.body]
  v(0.25em)
}

// ── Helper: numbered chapter headings ───────────────────────
#let chapter(number, title) = {
  pagebreak(weak: true)
  v(2em)
  align(left)[
    #text(size: 20pt, weight: "bold")[Chapter #number]
    #v(0.3em)
    #text(size: 18pt, weight: "bold")[#title]
  ]
  v(1.5em)
}

// ── Helper: section numbering within a chapter ──────────────
#let section(number, title) = {
  v(1em)
  text(size: 14pt, weight: "bold")[#number #h(0.5em) #title]
  v(0.5em)
}

#let subsection(number, title) = {
  v(0.8em)
  text(size: 12pt, weight: "bold")[#number #h(0.5em) #title]
  v(0.4em)
}


// ============================================================
//  TITLE PAGE
// ============================================================

#set page(numbering: none)

#v(3cm)

// If you have a university logo, place it in this folder and uncomment:
#align(center)[#image("UEL LOGO.png", width: 40%)]

#v(1cm)

#align(center)[
  #text(size: 14pt, weight: "bold")[
    SCHOOL OF ARCHITECTURE, COMPUTING AND ENGINEERING
  ]
  #v(0.3em)
  #text(size: 12pt)[
    Department of Engineering and Computing
  ]
]

#v(2cm)

#align(center)[
  #text(size: 22pt, weight: "bold")[
    Personalised Nutrition Recommendations \ Using XAI and Gut-Microbiome Data
  ]
]

#v(1.5cm)

#align(center)[
  #text(size: 14pt)[Zoya Shaikh]
  #v(0.3em)
  #text(size: 12pt)[Student ID: U2576800]
]

#v(2cm)

#align(center)[
  #text(size: 12pt)[
    A report submitted in part fulfilment of the degree of \
    *BSc (Hons) in Computer Science*
  ]
  #v(1em)
  #text(size: 12pt)[Supervisor: *Dhara Parekh*]
  #v(0.5em)
  #text(size: 12pt)[Module: CN6000]
  #v(0.5em)
  #text(size: 12pt)[30 January 2026]
]

#pagebreak()


// ============================================================
//  ABSTRACT
// ============================================================

#set page(numbering: "i")
#counter(page).update(1)

= Abstract

_Write your abstract here. Remember, an abstract is 500 words or less. It is NOT an introduction to your project. It has to have three elements: Purpose of this project, how you did the project, and what is the outcome of this project. You do not cite sources in your abstract. It is likely to be the last thing you write._

#pagebreak()


// ============================================================
//  ACKNOWLEDGMENTS
// ============================================================

= Acknowledgments

_Here you can thank the people, including your supervisor, who have helped you with your project._

#pagebreak()


// ============================================================
//  TABLE OF CONTENTS
// ============================================================

#outline(
  title: [Contents],
  indent: 1.5em,
  depth: 3,
)

#pagebreak()


// ============================================================
//  MAIN BODY — Switch to Arabic numbering
// ============================================================

#set page(numbering: "1")
#counter(page).update(1)

// Set numbered headings for main body
#set heading(numbering: "1.1")


// ────────────────────────────────────────────────────────────
//  CHAPTER 1 — INTRODUCTION
// ────────────────────────────────────────────────────────────

= Introduction <ch-introduction>

== Introduction


The increasing global impact of diet-related chronic illnesses, such as obesity, type 2 diabetes (T2D), and cardiovascular disease, emphasises the limitations of traditional "one-size-fits-all" nutritional regimens. Extensive data suggest that people have highly different metabolic reactions to the same foods due to complicated interactions between genetic, biological, lifestyle, and environmental factors @brankovic2025perspectives. This awareness has sparked increased interest in Personalised Nutrition (PN), a method of tailoring dietary recommendations to an individual's biological and metabolic profile rather than depending on nationwide standards.

The human gut microbiota (GM) is an important component of personalised nutrition, since it regulates digestion, food absorption, immunity control, and glucose metabolism @xie2024gut. The gut microbiome generates metabolites such as short-chain fatty acids (SCFAs), which impact disease and glycaemic regulation, making microbiome profiling a critical technique for predicting individual post-meal glucose responses @xie2024gut. Recent breakthroughs in AI-driven nutrition research have used microbiome profiles to explain why two people can react extremely differently to the same diet @brankovic2025perspectives. However, combining the huge amount of data required for tailored nutrition remains a significant technical issue. Relevant information frequently includes high-dimensional microbiome sequencing data, continuous physiological measurements such as continuous glucose monitoring (CGM), blood pressure readings, lifestyle habits, and extensive nutritional intake records @krishna2025ai. Artificial Intelligence (AI), namely Machine Learning (ML) and Deep Learning (DL), provides the computational capacity required to process such massive, complex datasets and deliver meaningful, flexible results.

Many AI models function as "black boxes," producing precise results with little interpretability despite their capacity for prediction. Adoption of AI-driven technologies in actual healthcare settings is challenging due to this lack of transparency, which erodes user and clinician confidence @krishna2025ai. Explainable Artificial Intelligence (XAI) approaches, which improve transparency by offering concise biological explanations for model predictions, are incorporated into the current work to solve this difficulty. AI-driven nutrition tools are transformed by XAI from unreadable systems into reliable transparent decision-support systems.


== Purpose of This Project

The goal of this project is to create an explainable AI-based system that uses personal health data and gut microbiome data to produce tailored food recommendations. In contrast to current nutrition guidelines, which offer generalised recommendations, the goal of this initiative is to provide individualised, accurate, data-driven dietary insights. Additionally, the system will help people, nutritionists, and health care professionals to better understand how biological aspects contribute to each advice through using explainability methodologies @krishna2025ai.


== Problem Statement

Personalised nutrition has becoming increasingly common, yet there are still significant obstacles to its adoption. Although gut microbiota significantly influences individual metabolic and glycaemic responses, many current systems do not fully integrate microbiome data @xie2024gut @brankovic2025perspectives.

Although deep learning models can generate extremely accurate predictions, they frequently lack interpretability, which lowers user confidence and restricts clinical application @krishna2025ai. Because of this, users are unable to pinpoint the precise elements that have influenced a particular dietary suggestion, such as microbial species, glucose patterns, or nutritional profiles @krishna2025ai.

Furthermore, because these datasets are heterogeneous, integrating multi-modal data—such as microbiome sequencing, continuous physiological signals, and nutritional intake records—remains computationally challenging @krishna2025ai @brankovic2025perspectives. In order to offer individualised dietary recommendations, an integrated AI model that can analyse complicated biological data and produce accessible, understandable, and reliable outputs is therefore required.


== Aim of the Project

The project's goal is to create an explainable AI-based personalised nutrition system that uses gut microbiome and individual health data to recommend foods.


== Objectives of the Project

+ To analyse current research on explainable AI, gut microbiome science, tailored nutrition, and AI models.
+ To collect and prepare nutritional, physiological, and microbiome data for model development.
+ To develop and put into use a predictive model based on Random Forest for customised dietary responses.
+ To incorporate Explainable AI techniques for transparent model output interpretation.
+ To evaluate the accuracy, reliability, and understanding of the model.
+ Discussion about the results, limitations, and possibilities for future development.


== Structure of the Project

- *Chapter 1 — Introduction:* Background, Purpose of the Project, Problem Statement, Aim of the Project, Objectives of the Project.
- *Chapter 2 — Literature Review:* Critical analysis of existing research.
- *Chapter 3 — Methodology:* Research design, system architecture, and implementation approach.
- *Chapter 4 — Results:* Findings and outcomes of the implemented system.
- *Chapter 5 — Evaluation:* Critical evaluation of product and process.
- *Chapter 6 — Conclusion:* Summary, limitations, and future work.


// ────────────────────────────────────────────────────────────
//  CHAPTER 2 — LITERATURE REVIEW
// ────────────────────────────────────────────────────────────

= Literature Review <ch-litreview>

== Introduction

Artificial intelligence's (AI) quick development has drastically changed healthcare, especially in the area of customised nutrition. Conventional dietary recommendations are primarily population-based and do not take individual differences in metabolism, lifestyle, and biological factors into consideration. According to recent studies, the gut microbiota plays a crucial role in determining an individual's nutritional responses, including immunological regulation, metabolism, digestion, and disease risk.

Therefore, combining gut microbiome data with AI-powered models offers a chance to provide highly customised dietary advice. But the growing intricacy of AI models has sparked questions about trust and transparency, particularly in healthcare settings. Therefore, Explainable Artificial Intelligence (XAI) has become a crucial element to guarantee understanding, accountability, and ethical implementation of AI-based nutrition systems. This chapter analyses the results of research on AI explanations in healthcare, gut microbiome-based dietary modelling, and AI-powered personalised nutrition. Additionally, it highlights research gaps and restrictions that support the necessity of the proposed study.


== Personalised Nutrition with Artificial Intelligence

The accuracy of machine learning models for tailored dietary recommendations has been extensively proven in recent years @zeevi2015personalised @benyacov2021personalised @bul2023ai. Nutrition science has made significant use of AI to transition from static dietary recommendations to personalised and adaptive systems. Complex datasets comprising dietary consumption, physiological measures, and behavioural data have been analysed using machine learning approaches like supervised learning, neural networks, and ensemble models. Based on personal traits, these algorithms seek to forecast health outcomes like illness risk, weight change, and glycaemic response.

Basic research in personalised nutrition shows that machine learning models surpass standard dietary recommendations by effectively predicting individual postprandial glycaemic responses using personal and microbiome data @zeevi2015personalised. This study shows that people respond differently to identical meals, exposing the shortcomings of population-based dietary guidelines. Subsequent research expanded on this methodology by including additional health indicators such as lipid profiles, insulin sensitivity, and lifestyle factors, demonstrating the efficacy of AI-powered personalised dietary therapies @benyacov2021personalised.

Many AI-based nutrition systems rely on complex black-box models that are difficult to understand, despite these promising outcomes. High predictive accuracy is useful, but the lack of transparency limits clinical adoption and presents ethical issues because consumers and medical professionals may find it difficult to comprehend the reasoning behind dietary recommendations @bul2023ai.


== The Gut-Microbiome Role in Nutrition and Health

The link between gut microbiota composition and individual dietary response has been extensively investigated in clinical and nutritional studies @zeevi2015personalised @rein2022gut @benyacov2023personalised. The gut microbiome is the varied group of microorganisms found in the human gastrointestinal system. A lot of research has demonstrated its importance in food metabolism, immunological function, and disease progression. Variations in microbial composition have been linked to obesity, type 2 diabetes, inflammatory bowel disease, and cardiovascular problems.

According to studies, the gut microbiota has a significant impact on individual responses to dietary intake, with some microbial profiles associated with positive metabolic outcomes and others associated with inflammation and poor glucose regulation @zeevi2015personalised @benyacov2021personalised @rein2022gut. This diversity explains why people who eat the same food may have drastically different health outcomes @zeevi2015personalised @bul2023ai.

Recent advances in microbiome analysis have allowed for large-scale study of microbiome data, making it possible to incorporate these insights into AI models @benyacov2021personalised. Several studies have linked microbiome features with clinical and nutritional data to tailor nutrition recommendations, resulting in higher prediction accuracy for metabolic outcomes @zeevi2015personalised @benyacov2021personalised @joshi2023digital. However, microbiome-based nutrition research confronts several problems, including high data dimensionality, inter-individual variability, and a lack of long-term datasets, with many studies prioritising prediction performance above interpretability and real-world applicability @bul2023ai.


== Machine Learning Methods for Microbiome-Based Nutrition Models

Previous research on microbiome-based nutrition modelling has used a variety of supervised and ensemble learning techniques, emphasising both interpretability issues and performance advantages @benyacov2021personalised @joshi2023digital. Random forests, support vector machines, gradient boosting, and deep learning architectures are often employed techniques.

Although deep learning models are frequently attacked for their lack of transparency, which restricts their use for clinical decision-making, they can achieve good prediction accuracy when adequate data is provided @bul2023ai @joshi2023digital. According to #cite(<benyacov2021personalised>, form: "prose") and #cite(<bul2023ai>, form: "prose"), tree-based models, on the other hand, offer limited feature importance metrics but are still unable to provide completely interpretable explanations appropriate for healthcare applications.

There is still a lack of consensus on the perfect methods for incorporating microbiome data into AI-driven nutrition systems, despite the proposal of mixed methods that combine statistical analysis and machine learning to balance performance and interpretability @joshi2023digital @bul2023ai.


== XAI in Healthcare

Recent healthcare literature has highlighted the significance of explainability in clinical AI systems, especially when AI-driven recommendations affect patient behaviour and medical decision-making @bul2023ai @jin2024gpt. The term "explainable AI" describes methods intended to improve trust, accountability, and regulatory compliance by making AI model decisions clear to people.

According to #cite(<bul2023ai>, form: "prose") and #cite(<jin2024gpt>, form: "prose"), XAI approaches like SHAP and LIME are frequently used to understand complex machine learning models by determining the contribution of particular attributes to model predictions. Explainable AI supports informed decision-making in nutrition and healthcare applications by helping stakeholders comprehend how particular microbial taxa or dietary components impact recommendations @bul2023ai @benyacov2021personalised.

According to recent research, explainable models assist in detecting bias and problems with data quality while also increasing user acceptability and confidence @bul2023ai @jin2024gpt. However, there is still little integration of XAI into microbiome-based nutrition systems, and many studies prioritise predicting accuracy above transparency @bul2023ai.


== Future Direction for AI in Personal Nutrition

Future developments in artificial intelligence will increasingly focus on solving current limits in order to create flexible, trustworthy, and clinically useful personalised nutrition (PN) systems @brankovic2025perspectives.

*Federated Learning (FL):* By allowing AI models to be trained across decentralised datasets, such as several hospitals or research centres, federated learning offers a promising solution to privacy, scalability, and generalisation issues without requiring sensitive data to be centrally shared @brankovic2025perspectives @probul2024ai. FL has the potential to enhance model robustness and generalisability by increasing the effective number and diversity of training data, especially in delicate healthcare domains @brankovic2025perspectives.

*Different Models:* Combining multiple sources of data, such as genetic, microbiome, nutritional, and lifestyle data, into cohesive multimodal frameworks is another new approach @brankovic2025perspectives. By understanding the intricate and dynamic relationships that affect individual health outcomes, such holistic approaches allow for more precise and practical recommendations.

*Adaptive and Dynamic Guidance:* Complex and changing environments where optimal solutions change over time are especially well-suited for advanced machine learning approaches like reinforcement learning (RL) @forman2019randomized @mulani2020reinforcement. RL allows systems to move beyond static, one-size-fits-all advice in the context of personalised nutrition by continuously adapting dietary recommendations based on continuous input and evolving health data @mulani2020reinforcement @brankovic2025perspectives.


== Gaps in the Literature

Although technology advances, some difficulties must be overcome before AI-powered PN can be used widely and fairly in clinical settings @brankovic2025perspectives.

*Gap 1: Security and Generalisation (Reliability Gap)* \
The poor predictability of current AI models across various populations is a significant gap in the field. When trained on local or homogeneous datasets, many microbiome-based personalised nutrition systems perform well, but when applied to independent cohorts from diverse geographic or demographic backgrounds, they lose accuracy @reitmeier2020handling @probul2024ai. According to #cite(<brankovic2025perspectives>, form: "prose"), this lack of cross-cohort robustness reveals a glaring deficiency in empirical validation utilising representative and heterogeneous datasets, which is crucial for trustworthy clinical implementation. This study aims to improve accuracy among individuals by evaluating personalised nutrition models utilising varied microbiome and health-related data in order to overcome this restriction.

*Gap 2: Efficiency, Collaboration, and Data Integrity* \
The availability and flexibility of multi-source data represent another significant gap. In order to produce correct recommendations, effective personalised nutrition systems must include gut microbiome, multi-omics, lifestyle, and clinical data @ozdemir2016precision @adams2020perspective. However, scalability, reproducibility, and cross-study comparison are severely impacted by the lack of defined types of data and accessible facilities @tsolakidis2024interoperability. A significant limitation of current research is the absence of a completely integrated framework in the literature that can facilitate smooth data collection across these areas at scale @brankovic2025perspectives. The proposed research fills this gap by using an integrated data architecture that integrates physiological, dietary, and microbial data into one research system.

*Gap 3: Limited Use of Explainable AI in Microbiome-Based PN Systems* \
Explainable AI (XAI) methods are being used more and more in healthcare, although they are still not widely used in microbiome-driven personalised nutrition systems. Medical reliability and ethical acceptability are impacted by the fact that many current models emphasise predictive performance while providing a lack of transparency @bul2023ai @joshi2023digital. Since explanation is crucial for assisting clinical decision-making and assuring responsibility in AI-powered healthcare applications, this constitutes an important gap in the literature. In order to improve transparency, develop trust, and support ethical use in personalised nutrition advice, this work integrates explainable artificial intelligence (AI) methods.


=== Comparing Current AI-Powered Personalised Nutrition Research

#figure(
  table(
    columns: 6,
    inset: 8pt,
    align: left,
    stroke: 0.5pt,
    fill: (x, y) => if y == 0 { rgb("#e8edf3") },
    table.header([*Research*], [*Data Used*], [*Model / Method*], [*XAI*], [*Key Outcomes*], [*Identified Gaps*]),
    [#cite(<zeevi2015personalised>, form: "prose")],
    [CGM, gut microbiota, dietary records],
    [ML group work],
    [None],
    [Highlighted individualised blood sugar reactions],
    [Particular cohort data and limited capability for interpretation],

    [#cite(<reitmeier2020handling>, form: "prose")],
    [Genetic sequencing of microbiomes],
    [ML and statistical models],
    [None],
    [Microbiome predictions were found to be unstable across groups],
    [Limited validity and generalised],

    [#cite(<ozdemir2016precision>, form: "prose")],
    [Multiple omics datasets],
    [Methods from biological systems],
    [Limited],
    [Data-driven PN frameworks that are suggested],
    [Absence of integrated, expandable systems],

    [#cite(<adams2020perspective>, form: "prose")],
    [Medical and behavioural data],
    [Models for machine learning],
    [Limited],
    [Improved accuracy in dietary recommendations],
    [Absence of microbiome integration],

    [#cite(<bul2023ai>, form: "prose")],
    [Health, behaviour and nutritional information],
    [AI-powered PN systems],
    [Partial],
    [Highlighted the prospective of PN in healthcare],
    [Limited ethical transparency and explainability],

    [#cite(<joshi2023digital>, form: "prose")],
    [Environmental and clinical data],
    [Models of identical devices],
    [None],
    [Established capacity to manage persistent diseases],
    [Absence of XAI and microbiome data],

    [#cite(<brankovic2025perspectives>, form: "prose")],
    [Analysing PN systems],
    [Concept evaluation],
    [Partial],
    [Identified PN's future directions],
    [Explainable, scalable, and generalisable AI is required],
  ),
  caption: [Comparison of current AI-powered personalised nutrition research],
) <tab-comparison>

The analysis indicates that current personalised nutrition systems lack an organised framework that integrates various health data sources, ensures consistency across populations, and generates clear, understandable predictions. This project aims to close these gaps by proposing an explainable AI-based personalised nutrition system that integrates lifestyle, clinical, and gut microbiome data to increase clinical relevance, scalability, and confidence.


== Chapter Summary

This chapter analysed important research on AI-driven personalised nutrition, with particular attention to explainable AI in healthcare, gut microbiome studies, and machine learning techniques. Previous research (e.g., @zeevi2015personalised; @adams2020perspective) shows that AI can enable customised dietary advice; nonetheless, the review found recurring gaps in related studies. #cite(<reitmeier2020handling>, form: "prose"), #cite(<bul2023ai>, form: "prose"), #cite(<brankovic2025perspectives>, form: "prose"), and other previous studies show limited predictability across populations, incomplete collection of microbiome and health data, and insufficient use of explainable AI to enhance transparency and ethical decision-making. The methodological approach used in this project is strongly influenced by these limitations, which underline the necessity for an explainable and integrated AI-based personalised nutrition system.


// ────────────────────────────────────────────────────────────
//  CHAPTER 3 — PROJECT METHODOLOGY
// ────────────────────────────────────────────────────────────

= Project Methodology <ch-methodology>

== Introduction

This chapter describes how an explainable artificial intelligence (XAI)-based personalised nutrition system was designed, implemented, and evaluated utilising individual health data and gut microbiome information. The methodological decisions were influenced by the research gaps identified in Chapter 2, particularly the limited integration of heterogeneous biological data, the lack of transparency in existing AI-driven nutrition systems, and concerns about generalisability and clinical trust @bul2023ai @brankovic2025perspectives.

A method of secondary quantitative research was used along with an Agile software development life cycle (SDLC) since personalised nutrition research is based on data and exploratory. Data collection, preprocessing, predictive modelling, explainability integration, and quantitative assessment make up the methodology's organised workflow. According to #cite(<amershi2019software>, form: "prose"), this methodology ensures methodological accuracy, reliability, and alignment with best practices in machine learning research focused on healthcare.


== Research Methodology Approach

This study uses a combination methodological approach that combines real-world system implementation with theoretical analysis. Theoretically, current research in explainable AI, machine learning in healthcare, gut microbiome characterisation, and personalised nutrition was examined by a systematic assessment of peer-reviewed literature. Model selection, explainability techniques, and evaluation standards were all directly influenced by the review's conclusions @joshi2023digital @jin2024gpt.

In practical terms, the project required developing an AI-powered system capable of assessing microbiome, nutritional, and physiological data and generating tailored dietary recommendations. The system was created to simulate postprandial metabolic responses while offering interpretable explanations for its predictions. This combined theoretical-practical approach assures that the proposed solution is both scientifically sound and useful in real-world personalised nutrition scenarios.


== Methodology: Software Development Life Cycle (SDLC)

=== SDLC Methodology: Agile

An Agile software development life cycle (SDLC) methodology was adopted for this project. This option was taken because the project uses a data-driven, research-focused methodology, and as knowledge of the issue grew, so did the requirements. Agile is especially well-suited for machine learning development since it necessitates iterative testing, assessment, and improvement @sommerville2016software.

Traditional methodologies, such as Waterfall or SSADM, require fixed requirements at the initial stages, making them unsuitable for machine learning systems. Agile emphasises iterative development, continuous evaluation, and gradual improvement, making it suitable for AI-driven healthcare solutions @sommerville2016software @amershi2019software.

=== SDLC Method: Kanban

A Kanban-based approach was used to manage development tasks within the Agile SDLC. Since only one developer was working on the project and formal sprint-based frameworks were not needed, Kanban was chosen as a flexible, lightweight task management method. Throughout the development lifecycle, tasks were arranged into well-defined stages to facilitate ongoing progress monitoring and effective planning.

Kanban-style stages were used to arrange the tasks, which included:

- Data preparation and preprocessing
- Model training and development
- Explainability analysis
- Evaluation and improvement

This method allows ongoing progress tracking and effective prioritising throughout the development process. Kanban was used purely for development management and had no impact on the research evaluation approach.


== Field Research Approach

This project uses a field research methodology to assess the efficacy of the suggested explainable artificial intelligence (XAI)-based personalised nutrition system. Using statistical analysis and numerical data, the evaluation focuses on objective performance assessment. This method guarantees that conclusions are grounded in quantifiable results rather than subjective interpretation, which is crucial for AI research focused on healthcare.

=== Supporting Research with a Literature Review

This project's theoretical structure was developed by a methodical examination of research papers that went through peer review. To determine current approaches, constraints, and research gaps, papers on AI-driven personalised nutrition, gut microbiome modelling, and explainable artificial intelligence in healthcare were examined @zeevi2015personalised @joshi2023digital.

Key design decisions, such as dataset selection, predictive model selection, explainability requirements, and evaluation criteria, were directly influenced by the findings of the literature research. The literature review does not make up for the field research methodology, even if it provides important context and justification. Instead, by basing methodological decisions on proven research, it facilitates the quantitative assessment of the suggested system @bul2023ai.

=== Method of Quantitative Research

For this research, a quantitative research methodology was used. Because the study assesses numerical physiological, nutritional, and microbiome-related data and uses objective statistical criteria to determine system performance, quantitative analysis is acceptable.

Quantitative methods are frequently employed in AI-based healthcare systems to verify system efficacy, analyse feature contributions, measure predictive accuracy, and evaluate model reliability @amershi2019software @jin2024gpt. This approach guarantees that outcomes are statistically based rather than interpretive, permits repeatable experimentation, and supports accurate comparison.

=== Method of Field Research: Evaluation Based on Datasets

The quantitative research was handled by using data-based evaluation. The suggested system's prediction performance and accessibility were assessed using publicly available benchmark datasets. Model outputs were examined using numerical performance metrics extracted directly from the datasets, allowing for an objective assessment of prediction quality and system performance.

This method is aligned with best practices in machine learning research, where model validation is done with structured datasets rather than qualitative methods like interviews or focus groups @forman2019randomized. Dataset-based quantitative evaluation ensures transparency, consistency, and methodological robustness.

=== Description and Selection of Datasets

This study used publicly available secondary datasets to help with the creation and quantitative evaluation of the proposed explainable artificial intelligence (XAI)-based personalised nutrition system. Secondary datasets were chosen to ensure ethical compliance, reproducibility, and compatibility with machine learning-based analysis @joshi2023digital.

Physiological and nutritional data were utilised to predict postprandial metabolic reactions, while dietary macronutrient and continuous glucose monitoring (CGM) data were used to capture individual metabolic responses. The CGMacros dataset was chosen as the primary data source for this project.

The CGMacros dataset provides real-world continuous glucose monitoring readings paired with detailed macronutrient intake records from multiple participants. The dataset includes time-series glucose measurements alongside corresponding carbohydrate, protein, fat, and caloric intake data, making it well-suited for modelling individual postprandial glycaemic responses in a personalised nutrition context @zeevi2015personalised @cgmacros2023dataset.

The CGMacros dataset was chosen for its high data quality, structured numerical format, and direct applicability to personalised nutrition research. Its combination of physiological glucose data with dietary intake records allows for meaningful analysis of how macronutrient composition influences individual glycaemic responses. Furthermore, the use of a publicly accessible secondary dataset ensures ethical compliance and supports repeatable quantitative evaluation @benyacov2021personalised.


== System Design and Implementation Techniques

This section outlines the specific methods and tools utilised to put the system into action.

=== Architecture of the System

The system consists of the following layered structure:

+ *Data Acquisition Layer:* Collecting physiological, nutritional, and microbial data.
+ *Data Preprocessing Layer:* Features are cleaned, normalised, and engineered.
+ *Predictive Modelling Layer:* A Random Forest ensemble model is used to forecast the postprandial glycaemic response.
+ *Explainability Layer:* Uses LIME and SHAP to analyse forecasts.
+ *Recommendation Layer:* Produces individualised, comprehensible dietary recommendations.

This architecture overcomes the weaknesses identified in earlier research by reflecting the need for both predictability and transparency.

// Note: Include Figure 3.1 here — System Architecture Block Diagram

=== Data Processing Approaches

Following best practices in healthcare and microbiome data analysis, data preprocessing procedures include data cleaning, normalisation, encoding, and feature engineering @reitmeier2020handling @benyacov2021personalised.

=== The Predictive Modelling Approach

The glucose response patterns were modelled using a Random Forest ensemble classifier. Random Forest was selected for its robustness against overfitting, its ability to handle high-dimensional microbiome and physiological data, and its built-in feature importance metrics which support the explainability objectives of this project @forman2019randomized.

// Note: Include Figure 3.2 here — Random Forest Architecture

=== Explainable Artificial Intelligence Approach

Model predictions were interpreted using explainable artificial intelligence approaches. Model outputs are converted into comprehensible explanations that show how physiological parameters, nutritional composition, and microbial characteristics affect specific dietary recommendations. This strengthens clinical relevance, encourages ethical responsibility, and increases user trust.

// Note: Include Figure 3.3 here — XAI Workflow (SHAP and LIME)


== Problems and Limitations

=== Implementation Problems

One of the most difficult aspects of this project's implementation was integrating various sources of data, such as gut microbiota profiles, dietary intake records, and continuous glucose monitoring (CGM) data. These datasets vary widely in structure, scale, and temporal resolution, necessitating intensive preprocessing to maintain consistency and compliance with machine learning models @reitmeier2020handling @tsolakidis2024interoperability.

Another major issue was reconciling forecast accuracy with model interpretability. While complex models can achieve high accuracy, ensuring that predictions remain transparent and clinically meaningful requires careful integration of explainable AI techniques @bul2023ai @joshi2023digital.

=== Research Limitations

One significant disadvantage of this study is its dependence on secondary datasets rather than real-time or longitudinal clinical data. As a result, the system has not been validated in live healthcare settings, limiting its immediate clinical utility @adams2020perspective @brankovic2025perspectives.

Furthermore, the generalisability of the suggested model may be limited by dataset size and population variety. Previous research has found that microbiome-based models generally perform poorly when used across diverse cohorts, emphasising issues with robustness and external validity @reitmeier2020handling @probul2024ai.

Despite these limits, the identified issues suggest clear routes for future study, such as using larger, more diverse datasets and privacy-preserving methodologies like federated learning to improve model robustness and scalability @brankovic2025perspectives.


== Resources and Tools

=== Hardware

The study was carried out on a personal computer that had enough memory and processing capability to perform quantitative evaluation, machine learning model training, and data preparation. The system's multi-core CPU and integrated graphics were sufficient for the size and complexity of the datasets employed, including physiological and gut microbiome data, despite the lack of a separate high-performance GPU.

=== Software

A carefully chosen software framework was used to assist in the development, evaluation, and interpretation of the proposed explainable AI-based personalised nutrition system. The tools were chosen for their capacity to analyse quantitative data, experiment with machine learning, and conduct reliable research.

The main programming language was Python because of its broad support for machine learning and data analysis @vanrossum2009python. Jupyter Notebook was utilised for preprocessing, iterative model construction, and data exploration. The Random Forest model was trained and implemented using Scikit-learn. Data management and numerical computation were handled using Pandas and NumPy, and visualisation was done with Matplotlib and Seaborn. SHAP and LIME were used to create explainable AI approaches to facilitate model prediction interpretation @lundberg2017unified.


== Ethical Concerns

Because the health, nutritional, and gut microbiota data were highly sensitive data, legal issues were crucial to this research. All datasets utilised in this work were encrypted and derived from publicly accessible or ethically approved research sources, ensuring that no personally identifying information was handled or retained. This technique follows ethical criteria for healthcare and data-driven research @ozdemir2016precision @adams2020perspective.

Introducing explainable artificial intelligence improves ethical AI concepts by increasing transparency, responsibility, and user trust. Explainable models help consumers and healthcare professionals understand how specific aspects affect dietary recommendations, lowering the hazards associated with opaque "black-box" decision-making systems @bul2023ai @jin2024gpt.

In addition, the research acknowledges that AI-based nutrition systems should complement, rather than replace, human medical judgment. As a result, the established system is solely for academic and research purposes and does not offer clinical diagnosis or medical advice. Ethical responsibility, data privacy, and fairness were prioritised throughout the system design in line with best practices in personalised nutrition and healthcare AI research @brankovic2025perspectives.


== Chapter Summary

This chapter describes the methodological framework used to create and construct the suggested explainable AI-powered personalised nutrition system. A secondary quantitative research strategy, along with an Agile software development life cycle, allowed for repeated testing, continual improvement, and systematic evaluation of both prediction performance and accessibility.

The combination of Random Forest-based modelling and explainable AI techniques like SHAP and LIME directly addresses key limitations identified in previous personalised nutrition research, particularly a lack of transparency and trust in AI-driven healthcare systems @bul2023ai @brankovic2025perspectives. Furthermore, the methodological choices taken in this work were motivated by limitations identified in the literature analysis, such as problems related to data heterogeneity, generalisability, and ethical AI deployment in healthcare settings @reitmeier2020handling @adams2020perspective.

All things considered, this methodology offers a solid and ethical basis for studying the system's output and assessing how well it works in the upcoming chapters.


// ────────────────────────────────────────────────────────────
//  CHAPTER 4 — IMPLEMENTATION
// ────────────────────────────────────────────────────────────

= Implementation <ch-implementation>

This chapter provides a comprehensive account of the system implementation, detailing the architectural design, backend development, frontend interface, data processing pipeline, and integration of machine learning and explainability components. The implementation follows a modern, full-stack architecture designed to provide seamless integration between multimodal data inputs, predictive modelling, and user-facing interfaces for personalised nutrition recommendations.

== System Architecture Overview

The explainable AI-based personalised nutrition system was implemented using a layered, modular architecture comprising five interconnected components: (1) the data acquisition layer, (2) the backend processing layer, (3) the machine learning inference layer, (4) the explainability layer, and (5) the frontend presentation layer. This architectural approach follows established best practices for healthcare AI systems, ensuring separation of concerns, scalability, and maintainability @amershi2019software.

The system accepts two primary input modalities: food images captured by users and manually entered nutritional macronutrient data. Both pathways converge into a unified prediction pipeline that leverages machine learning for glucose spike prediction, SHAP-based explainability analysis, and Large Language Model (LLM) integration for generating clinically-informed personalised recommendations. The architecture was designed to prioritise data security, user privacy, and transparency in all decision-making processes.

=== Architectural Layers and Components

The system architecture comprises five interconnected layers, each with specific responsibilities:

*Frontend Layer (React 18 + Vite):* The presentation layer consists of seven React components: Login (authentication), Onboarding (user orientation), PremiumDashboard (primary interface), PatientHistory (longitudinal data), Header/Footer (navigation), ImageUpload (food recognition interface), and ManualEntry (form-based input). State management utilises React hooks for efficient component rendering and data flow between components.

*Backend Layer (FastAPI + Uvicorn):* The API server exposes three primary REST endpoints: (1) POST /api/predict for manual meal predictions, (2) POST /api/analyse-food-image for CNN-based food classification, and (3) POST /api/predict-from-image for end-to-end image-to-prediction pipeline. Input validation through Pydantic models ensures data integrity before processing.

*Machine Learning Layer:* Integrated ML components include: (1) CNN Food Classifier using Google Gemini Vision APIs with multi-model fallback capability, (2) Random Forest ensemble model for glucose spike prediction, (3) SHAP TreeExplainer for feature attribution analysis, and (4) Google Gemini 2.5 Flash LLM for clinical advice generation.

*Data Layer:* Persistent storage uses dual mechanisms: SQLite database for encrypted long-term storage and JSON cache for rapid session-based retrieval. Nutritional data for 75+ common foods is embedded within the system. Patient demographic and microbiome profiles are maintained in CSV format for efficient model inference.

*Security Layer:* Fernet symmetric encryption protects data at rest. CORS configuration restricts API access to authorised frontend domains. Environment variables securely manage API credentials, ensuring credentials are never hardcoded in source code.

== Backend Implementation

=== Technology Stack and Framework

The backend was implemented using FastAPI, a modern Python web framework designed for building high-performance APIs with automatic documentation and type validation @vanrossum2009python. FastAPI was selected for its speed, asynchronous request handling capabilities, and seamless integration with machine learning libraries. The backend server runs on Uvicorn, a lightweight ASGI server optimised for production environments.

The backend system manages three critical functions: (1) receiving and processing input data from the frontend, (2) orchestrating machine learning predictions and explainability analysis, and (3) generating personalised recommendations through LLM integration. All operations follow a secure, encrypted pipeline to protect sensitive health information.

=== Endpoints and API Design

The system implements three primary REST API endpoints to facilitate different user workflows:

*Endpoint 1: Manual Meal Prediction (/api/predict).* This endpoint accepts manually entered nutritional parameters (carbohydrates, protein, fiber, calories) along with patient demographic data and microbiome profile information. The system validates input data, applies the trained Random Forest model to predict postprandial glucose spike magnitude, and generates SHAP-based visual explanations. The prediction workflow follows the functional pipeline:

```python
Input: MealInput(patient_id, microbiome_type, carbs, fiber, protein, calories)
├─ Data Validation
├─ Random Forest Prediction
├─ SHAP Explainability Analysis
└─ Output: Predicted glucose spike + explanation + LLM advice
```

*Endpoint 2: Food Image Classification (/api/analyse-food-image).* This endpoint accepts food image uploads, applies CNN-based food recognition to extract the food item name with confidence scores, and retrieves associated nutritional data from an embedded nutrition database. The CNN uses a multi-model fallback chain to ensure system resilience when API quotas are exceeded @krishna2025ai.

*Endpoint 3: Full Image-to-Prediction Pipeline (/api/predict-from-image).* This endpoint combines food image classification with nutritional prediction, allowing users to simply upload a food image and receive immediate glucose impact predictions without manually entering nutritional values. This streamlined workflow significantly improves user experience by reducing data entry burden.

All three endpoints return structured JSON responses containing prediction values, SHAP visualisation data (encoded as base64 images), and LLM-generated clinical insights. Furthermore, all predictions are persisted to an encrypted patient history database for longitudinal tracking and clinical review.

=== Data Processing and Validation

Input data undergoes rigorous validation and preprocessing before model inference:

+ *Type Validation:* The Pydantic BaseModel automatically validates that input parameters match expected data types and are within acceptable ranges.
+ *Caloric and Macronutrient Consistency Checks:* The system validates that macronutrient inputs are logically consistent (e.g., total calories roughly correspond to macronutrient energy contributions).
+ *Drink Detection Mechanism:* A specialised drink detection function identifies beverages based on nutritional signatures (carbohydrates ≤ 1.0g, calories ≤ 15, protein ≤ 1.0g). When drinks are detected, the system bypasses the Random Forest model and directly predicts a 1 mg/dL glucose spike, which aligns with clinical reality that non-caloric beverages produce negligible glycaemic response @krishna2025ai.

=== Machine Learning Model Integration

The trained Random Forest model (glucose_rf_model.pkl) is loaded into memory at server startup using the Joblib serialisation library. This enables sub-millisecond prediction latency during inference. The Random Forest was trained to predict postprandial glucose spike magnitude based on nutritional macronutrient composition and patient demographic features including microbiome profile classification.

Patient demographic and microbiome data are retrieved from a CSV file (patient_profiles.csv), which contains normalised representations of microbiome taxa and clinical biomarkers for multiple patient cohorts. When a prediction request arrives, the system identifies the appropriate patient record using a modulo-based safe indexing mechanism to prevent out-of-bounds array access:

```python
safe_index = patient_id % len(patient_profiles)
patient_data = patient_profiles.iloc[[safe_index]].copy()
patient_data['Carbs'] = meal.carbs
patient_data['Fiber'] = meal.fiber
patient_data['Protein'] = meal.protein
patient_data['Calories'] = meal.calories
prediction = rf_model.predict(patient_data)[0]
```

This approach ensures that any patient ID generates a valid prediction while maintaining computational efficiency for production environments.

=== Explainability Implementation

Model predictions are accompanied by comprehensive SHAP-based explainability analysis, which provides users and clinicians with transparent insight into which nutritional and demographic features drive each prediction. The system uses the TreeExplainer from the SHAP library, specifically designed for tree-based models like Random Forest @lundberg2017unified.

For each prediction, the system generates a SHAP waterfall plot illustrating:
+ The base model prediction value (expected value)
+ Feature contributions ranked by magnitude
+ Direction of each feature's impact (increasing or decreasing predicted glucose spike)
+ Final prediction value

The waterfall plot is rendered to PNG format, encoded as base64, and returned to the frontend for display to the user. This visual representation transforms the Random Forest's internal feature importance metrics into clinically-meaningful explanations that help users understand why a particular meal is predicted to cause a specific glucose impact.

=== LLM-Based Clinical Advice Generation

Following prediction and explainability analysis, the system leverages Google Gemini 2.5 Flash LLM to generate personalised clinical insights tailored to the user's microbiome profile and meal composition. The LLM receives a detailed prompt incorporating:

+ The exact predicted glucose spike magnitude
+ Macronutrient composition (carbs, protein, fiber, fat)
+ The user's classified microbiome profile
+ Clinical context about gut bacterial interactions with macronutrients

The LLM generates a response following a strict clinical format:
+ One introductory sentence explaining the clinical relevance
+ Clinical Insight: Explaining which macronutrients and gut bacteria drive the prediction
+ Action Plan: Recommending specific dietary modifications or physical interventions

This structured output ensures clinical coherence and actionability while maintaining transparency about the sources of dietary recommendations. The system includes robust fallback mechanisms; if the LLM API becomes unavailable, the system generates rule-based advice based on nutritional heuristics, ensuring uninterrupted service availability.

=== Data Security and Encryption

Patient data privacy is implemented through multiple layers of security:

+ *Encrypted Storage:* Sensitive patient conversations are encrypted using Fernet symmetric encryption (cryptography library) before persisting to SQLite database.
+ *Encrypted JSON Cache:* An additional JSON-based patient history is maintained with encrypted content for redundancy and session-based retrieval.
+ *Environment Variable Protection:* API keys for Google Gemini are loaded from environment variables (.env file) and never hardcoded in source files.
+ *CORS Configuration:* Cross-Origin Resource Sharing (CORS) is configured to only accept requests from authorised frontend domains (localhost:3000 and localhost:5173 during development).

All these security measures align with established practices in healthcare data protection and comply with principles of data minimisation and encryption-at-rest @ozdemir2016precision.

== Food Classification: CNN Implementation

=== Multi-Model Fallback Chain

The CNN-based food classifier implements an intelligent fallback chain to handle API quota limitations and ensure system resilience @krishna2025ai. The system attempts classification through multiple pathways in sequence:

1. *Primary Model (Gemini 2.5 Flash):* Optimised for visual understanding with quota of 20 requests/day
2. *Backup 1 (Gemini 1.5 Flash):* More capable model with 1500 requests/day quota
3. *Backup 2 (Gemini 1.5 Flash-8B):* Lightweight variant with 1500 requests/day quota
4. *Final Fallback (Offline Detection):* Rule-based classifier using image colour analysis and filename pattern matching

This cascade approach ensures that food classification remains functional even when primary API services experience quota exhaustion or temporary outages.

=== Nutrition Database Integration

The system embeds a comprehensive nutrition database containing nutritional profiles (calories, carbohydrates, protein, fiber, fat per 100g) for 75+ common foods across multiple cuisine types (fruits, vegetables, grains, proteins, prepared meals, regional dishes). When the CNN identifies a food item with high confidence, the system automatically retrieves the associated nutritional profile.

Users can optionally specify portion size in grams; the system scales all nutritional values proportionally. For example:

```python
scale = portion_grams / 100.0
calories = round(nutrition_data["calories"] * scale, 1)
```

This enables accurate prediction of glucose spikes for variable portion sizes, critical for personalised nutrition since identical foods in different quantities produce different glycaemic responses @zeevi2015personalised.

== Frontend Implementation

=== Technology Stack

The frontend was implemented using React 18 with Vite as the build tool, providing rapid development cycles and optimised production bundles. The application is styled using CSS modules, ensuring component-scoped styling without global namespace pollution. State management is handled through React hooks (useState, useContext), allowing efficient component re-rendering and data flow @vanrossum2009python.

=== User Interface Architecture

The frontend comprises seven primary React components:

*ConnectionTest Component:* Verifies that the frontend can establish communication with the FastAPI backend. This diagnostic component helps identify network connectivity or backend service issues during development and debugging.

*Login Component:* Implements user authentication, accepting patient ID and microbiome profile information. The patient ID is used to retrieve personalised demographic data and historical recommendations. This component establishes the session context for all subsequent predictions.

*Onboarding Component:* Guides first-time users through system orientation, explaining how to use food image upload, manual meal entry, and how to interpret glucose spike predictions and explanations.

*Header and Footer Components:* Provide consistent navigation and branding across all application pages, including links to patient history and clinical information resources.

*PremiumDashboard Component:* The primary user interface presenting the core functionality. This component manages state for:
+ Patient identification and microbiome profile
+ Meal input method selection (image upload vs. manual entry)
+ Prediction results display with glucose spike magnitude
+ SHAP visualization rendering
+ LLM-generated clinical advice

The Dashboard is styled with PremiumDashboard.css, implementing a professional healthcare-oriented design with clear information hierarchy, accessible colour schemes, and responsive layout for mobile and desktop viewing.

*PatientHistory Component:* Displays a temporal record of all predictions for a patient, allowing users to track glucose responses over time and identify dietary patterns. Historical data is retrieved from the encrypted backend database and presented in chronological order.

=== Frontend-Backend Integration

The React frontend communicates with the FastAPI backend through asynchronous HTTP requests using the Fetch API. Key interaction flows:

*Image Upload Workflow:*
```
User uploads image
  ↓
FormData prepared with image file
  ↓
POST to /api/analyse-food-image
  ↓
CNN classification and nutrition extraction
  ↓
Display detected food + confidence + nutrition
  ↓
Option to proceed with prediction or adjust values
```

*Prediction Workflow:*
```
User submits meal data (manual or from image)
  ↓
POST to /api/predict with MealInput
  ↓
Random Forest prediction + SHAP analysis
  ↓
LLM generates clinical advice
  ↓
Response includes predicted spike + SHAP image + advice text
  ↓
Frontend renders results with visualizations
  ↓
Save to patient history
```

All async operations include error handling to gracefully degrade if backend services become unavailable, displaying user-friendly error messages rather than technical stack traces.

== Data Pipeline and Integration

=== End-to-End Workflow

The complete system workflow from food input to personalised recommendation follows these integrated steps:

1. *Input Acquisition:* User provides food as either image or manual nutritional entry
2. *CNN Classification* (if image input): Computer vision model identifies food item
3. *Nutrition Extraction:* System retrieves or calculates macronutrient values
4. *Drink Detection Filter:* System checks if item is beverage; if so, bypasses ML model
5. *Predictive Modelling:* Random Forest predicts glucose spike magnitude
6. *Explainability Analysis:* SHAP generates visual and quantitative explanations
7. *LLM Integration:* Gemini generates personalised clinical insight
8. *Persistence:* Encrypted storage of prediction and advice to patient history
9. *Frontend Rendering:* Display prediction, explanation, and advice to user

This pipeline integrates four distinct technologies (CNN, Random Forest, SHAP, LLM) into a seamless, unified system where output from each component feeds into the next, creating an end-to-end decision-support system.

=== Database Architecture

Patient data is persisted across two complementary storage mechanisms:

*SQLite Database (data/history.db):* Permanent, encrypted storage of patient conversations and predictions. Uses Fernet encryption to encrypt content before writing to disk, ensuring that even database file access does not compromise patient privacy. Each record contains session ID, timestamp, actor (User or AI), and encrypted content.

*JSON Cache (clinical_history.json):* Session-based cache of recent interactions, allowing rapid retrieval of patient history without database queries. Provides failover capability if SQLite becomes unavailable.

Both storage mechanisms maintain referential integrity through consistent session ID management, allowing seamless switching between storage backends without data loss.

== Key System Features

=== Microbiome Profile Integration

The system accepts user-specified microbiome profile classifications (e.g., "Firmicutes-dominant", "Bacteroides-dominant", "Dysbiotic") and incorporates this information into both prediction and recommendation generation. This design choice reflects current research demonstrating that gut microbiota composition significantly influences postprandial glucose response and dietary tolerance @zeevi2015personalised @benyacov2021personalised.

While the current implementation uses categorical microbiome classifications, the architecture supports future integration of high-dimensional microbiome data (relative abundance of specific taxa, alpha/beta diversity metrics) without requiring system modifications.

=== Portion Size Flexibility

Users can specify meal portion sizes in grams, enabling the system to scale nutritional predictions accordingly. This feature recognises that while nutritional databases typically provide per-100g values, real-world meals vary in consumption quantity. The proportional scaling ensures glucose spike predictions accurately reflect actual meal consumption rather than standardised reference portions.

=== Fallback and Resilience Mechanisms

The system incorporates multiple resilience strategies:

+ *Multi-model CNN fallback:* Four sequential classification attempts before defaulting to offline detection
+ *LLM fallback:* Rule-based advice generation if LLM API becomes unavailable
+ *Safe indexing:* Modulo-based patient record retrieval prevents out-of-bounds errors
+ *Error handling:* Try-catch blocks at all external API integration points

These mechanisms ensure the system maintains functionality even when individual components experience temporary failures, supporting high availability for healthcare applications.

=== Clinical Context Preservation

The system maintains clinical context throughout the prediction pipeline. Each recommendation explicitly references the user's microbiome profile, specific macronutrient composition, and predicted glucose magnitude. This design ensures that recommendations are transparently connected to underlying data and predictions, supporting informed decision-making by users and clinicians.

== User Interface Flow and Navigation

The system implements a nine-step user journey designed to minimise cognitive load while providing comprehensive functionality. The flow begins with user authentication (Login Component), followed by optional first-time user orientation (Onboarding Component). New and returning users then access the Premium Dashboard, the central hub for all system interactions.

Users select their input methodology: either food image upload (requiring image selection, preview, and portion size specification) or manual nutritional entry (requiring carbohydrate, protein, fibre, and caloric input). Both pathways converge into a unified prediction processing phase, where the system executes Random Forest prediction, SHAP analysis, and LLM-based advice generation concurrently.

Results are presented across four components: (1) prominent glucose spike magnitude display, (2) SHAP waterfall visualisation showing feature contributions, (3) LLM-generated clinical insight explaining the physiological basis for the prediction, and (4) actionable plan recommending specific dietary or physical interventions.

Following results display, users can proceed to three distinct follow-up actions: logging an additional meal (returning to the Dashboard), reviewing complete prediction history (accessing the PatientHistory component), or adjusting system settings. The PatientHistory component displays temporal trends in glucose responses, enabling users to identify dietary patterns and track the effectiveness of dietary modifications over time.

This navigation structure ensures accessibility for novice users while providing advanced analytics for clinically-engaged users seeking detailed dietary pattern analysis.

== System Architecture Diagram

The complete system architecture integrates five layers with specific responsibilities:

```
┌────────────────────────────────────────────────────────────┐
│ 🖥️  FRONTEND LAYER (React 18 + Vite)                       │
│ ├─ Login | Onboarding | PremiumDashboard                   │
│ ├─ PatientHistory | ImageUpload | ManualEntry              │
│ └─ Header/Footer Navigation                                │
└────────────┬─────────────────────────────────────────────────┘
             │ HTTP/REST API
┌────────────▼─────────────────────────────────────────────────┐
│ 🔧 BACKEND LAYER (FastAPI + Uvicorn)                       │
│ ├─ POST /api/predict (Manual Prediction)                   │
│ ├─ POST /api/analyse-food-image (CNN Classification)       │
│ ├─ POST /api/predict-from-image (Full Pipeline)            │
│ └─ Input Validation & Drink Detection Filter               │
└────────────┬─────────────────────────────────────────────────┘
             │
┌────────────▼─────────────────────────────────────────────────┐
│ 🤖 MACHINE LEARNING LAYER                                   │
│ ├─ CNN Food Classifier (Gemini Vision Multi-model)         │
│ ├─ Random Forest Model (Glucose Prediction)                │
│ ├─ SHAP TreeExplainer (Feature Attribution)                │
│ └─ Google Gemini LLM (Clinical Advice)                     │
└────────────┬─────────────────────────────────────────────────┘
             │
┌────────────▼─────────────────────────────────────────────────┐
│ 💾 DATA LAYER                                               │
│ ├─ SQLite Database (Encrypted Patient History)             │
│ ├─ JSON Cache (Session-based retrieval)                    │
│ ├─ Patient Profiles CSV (Demographics + Microbiome)        │
│ └─ Nutrition Database (75+ Foods)                          │
└────────────┬─────────────────────────────────────────────────┘
             │
┌────────────▼─────────────────────────────────────────────────┐
│ 🔐 SECURITY LAYER                                           │
│ ├─ Fernet Encryption (At-Rest)                             │
│ ├─ CORS Configuration (Domain Validation)                  │
│ └─ Environment Variables (API Keys)                        │
└─────────────────────────────────────────────────────────────┘
```

== Backend API Pipeline and Data Processing

The backend processing pipeline implements a standardised request-response flow with five distinct phases:

*Phase 1 — Request Validation:* The frontend sends HTTP requests containing meal data (image file or nutritional macronutrients). The backend validates CORS headers, parses request bodies using Pydantic models, and enforces type constraints.

*Phase 2 — Processing:* A drink detection filter identifies beverages based on nutritional signatures (carbohydrates ≤ 1.0g, calories ≤ 15, protein ≤ 1.0g). For detected drinks, the system immediately returns a 1 mg/dL spike prediction. For non-beverage meals, the system retrieves patient demographic data from the CSV file, executes Random Forest prediction, and calculates SHAP feature contributions.

*Phase 3 — Explainability:* The system generates SHAP waterfall visualisations illustrating feature contributions to the final prediction. Each feature is ranked by absolute contribution magnitude, with direction indicators (increase/decrease) showing how each feature impacts the predicted glucose spike.

*Phase 4 — LLM Integration:* The system creates a structured prompt incorporating the exact predicted spike magnitude, macronutrient composition, and user's microbiome profile. Google Gemini API generates a response following a strict format (Clinical Insight + Action Plan). If the API becomes unavailable, a rule-based fallback mechanism generates clinically-relevant advice based on macronutrient heuristics.

*Phase 5 — Persistence and Response:* All data is encrypted using Fernet symmetric encryption, persisted to both SQLite (primary) and JSON cache (secondary), and returned to the frontend as a structured JSON response including base64-encoded SHAP visualisations.

== Complete End-to-End Image-to-Prediction Workflow

The image-to-prediction pipeline orchestrates six interconnected components:

(1) *Food Image Recognition:* User uploads image; CNN classifier attempts identification through four sequential models (Gemini 2.5 Flash, Gemini 1.5 Flash, Gemini 1.5 Flash-8B, offline detection). Fallback chain ensures functionality even when primary API quotas are exhausted.

(2) *Nutrition Extraction:* System retrieves nutritional profile from embedded database (calories, carbohydrates, protein, fibre, fat per 100g). User specifies portion size; system scales all values proportionally.

(3) *Drink Detection:* System checks if item meets beverage criteria. If true, returns 1 mg/dL response; if false, continues to prediction.

(4) *Glucose Prediction:* Random Forest model receives patient demographics and scaled macronutrient data, predicting postprandial glucose spike magnitude.

(5) *Explainability Analysis:* SHAP TreeExplainer calculates feature contributions, generating waterfall visualisation showing how each input feature (carbohydrates, protein, fibre, calories, patient demographics) influences the final prediction.

(6) *Clinical Advice Generation:* LLM receives prediction context and generates personalised insight and actionable recommendations, which are then persisted to encrypted storage.

This six-step workflow transforms raw food imagery into evidence-backed, explainable nutritional recommendations with clinical context, demonstrating the seamless integration of computer vision, machine learning, explainability, and language models into a unified healthcare AI system.

== Chapter Summary

This chapter detailed the comprehensive implementation of an explainable AI-based personalised nutrition system integrating food image recognition, machine learning prediction, explainability analysis, and LLM-based clinical advice generation. The system architecture prioritises data security, clinical relevance, and user transparency through modular design and multiple layers of security.

The backend implementation leverages FastAPI for high-performance API serving, integrates a pre-trained Random Forest model for glucose spike prediction, implements SHAP for transparent explainability, and incorporates Google Gemini for clinically-informed personalised advice. The frontend provides an intuitive React-based interface supporting both food image upload and manual meal entry pathways.

Data security is ensured through encryption at rest, secure API credential management, and encrypted patient history storage. The system's modular architecture and fallback mechanisms support high availability and graceful degradation when individual components experience service disruptions.

By integrating multiple AI technologies (computer vision, ensemble learning, explainability frameworks, and large language models) into a unified system, the implementation demonstrates how modern AI techniques can be orchestrated to create transparent, trustworthy healthcare decision-support systems that maintain clinical relevance while providing user-understandable explanations for all recommendations.


// ────────────────────────────────────────────────────────────
//  CHAPTER 5 — EVALUATION
// ────────────────────────────────────────────────────────────

= Evaluation <ch-evaluation>

_Include an evaluation of both product and process. You need to be objective in evaluating your work. Make sure you have a reflection here on what worked and what did not work._


// ────────────────────────────────────────────────────────────
//  CHAPTER 6 — CONCLUSION
// ────────────────────────────────────────────────────────────

= Conclusion <ch-conclusion>

_Write the conclusion of your project as well as any information related to future work. Remember to reflect on the key findings, limitations of these findings, and future opportunities to extend this work._


// ────────────────────────────────────────────────────────────
//  REFERENCE LIST
// ────────────────────────────────────────────────────────────

#set heading(numbering: none)

#bibliography("reference.bib", title: "Reference List", style: "harvard-cite-them-right")

// ────────────────────────────────────────────────────────────
//  APPENDICES
// ────────────────────────────────────────────────────────────

= Appendix A — System Architecture & Wireframes <appendix-wireframe>

== A.1 — Dashboard UI Component Layout

The Premium Dashboard implements a hierarchical layout structure optimising for information accessibility and functional clarity:

*Header Section:* Displays system branding (NUTRI-AI), current patient ID, selected microbiome profile, and navigation buttons for settings and history access.

*Input Section:* Presents two mutually-exclusive input options: (1) Image Upload with live preview and portion size slider (100-500g), enabling food classification via computer vision; (2) Manual Meal Entry with numerical input fields for macronutrient composition (carbohydrates, protein, fibre, calories). A switch button allows users to transition between methodologies without re-entering data.

*Results Section:* Displays prediction outcomes across four integrated components: (1) Prominent glucose spike magnitude (large numerical display with units mg/dL), (2) SHAP waterfall chart visualising feature contributions ranked by magnitude, (3) Clinical insight text explaining physiological mechanisms driving the prediction, (4) Action plan with specific, actionable recommendations tailored to the user's microbiome profile and meal composition.

*History Section:* Shows recent predictions (last 5 meals) in reverse chronological order, displaying food name, predicted spike magnitude, and timestamp. Users can access full patient history timeline via dedicated button.

*Footer Section:* Provides navigation links to help resources, privacy information, and logout functionality.

== A.2 — User Navigation Flow Diagram

The system implements a nine-state user journey:

```
State 1: Login
├─ Patient ID entry
├─ Microbiome profile selection
└─ Authentication

State 2: First-Time User?
├─ YES → Onboarding (tutorial & orientation)
└─ NO → Dashboard

State 3: Dashboard (Central Hub)
├─ Meal input selection

State 4A: Image Upload Path
├─ File selection
├─ Preview
├─ Portion adjustment
└─ Analyse

State 4B: Manual Entry Path
├─ Carbs input
├─ Protein input
├─ Fibre input
├─ Calories input
└─ Predict

State 5: Processing
├─ RF prediction
├─ SHAP analysis
└─ LLM generation

State 6: Results Display
├─ Glucose spike
├─ SHAP chart
├─ Clinical insight
└─ Action plan

State 7: Follow-up Action
├─ Log another meal → State 3
├─ View history → State 8
└─ Settings → State 9

State 8: Patient History
├─ Timeline view
├─ Trend analysis
└─ Export option

State 9: Settings
├─ Profile modification
└─ Return to Dashboard
```

== A.3 — Backend API Request/Response Pipeline

The backend processing pipeline implements five standardised phases:

*Phase 1 — Request Validation:*
- CORS header validation
- Request body parsing (Pydantic models)
- Type constraint enforcement
- Content-type validation

*Phase 2 — Processing:*
- Drink detection filter (carbs ≤ 1g, calories ≤ 15, protein ≤ 1g)
- If drink detected → 1 mg/dL spike response
- If meal → Patient profile retrieval → RF prediction
- SHAP calculation for feature contributions

*Phase 3 — Explainability:*
- Waterfall plot generation
- Feature ranking by contribution magnitude
- Direction indicators (increase/decrease effects)
- PNG rendering and base64 encoding

*Phase 4 — LLM Integration:*
- Structured prompt creation
- Gemini API invocation
- Response parsing
- Fallback rule-based generation if API unavailable

*Phase 5 — Persistence & Response:*
- Data encryption (Fernet)
- SQLite storage (primary)
- JSON cache storage (secondary)
- JSON response formatting
- Base64 SHAP image inclusion
- HTTP response transmission

== A.4 — Complete Image-to-Prediction Pipeline

The six-step end-to-end workflow:

*Step 1 — Food Image Recognition:*
```
User uploads image
    ↓
CNN Classifier
├─ Attempt 1: Gemini 2.5 Flash (quota: 20/day)
├─ Attempt 2: Gemini 1.5 Flash (quota: 1500/day)
├─ Attempt 3: Gemini 1.5 Flash-8B (quota: 1500/day)
└─ Attempt 4: Offline detection (colour + filename)
    ↓
Food detected with confidence score
```

*Step 2 — Nutrition Extraction:*
```
Database lookup: Food → Nutritional profile
├─ Per 100g values
│  ├─ Calories
│  ├─ Carbohydrates
│  ├─ Protein
│  ├─ Fibre
│  └─ Fat
    ↓
User specifies portion (e.g., 150g)
    ↓
Proportional scaling (150g ÷ 100g = 1.5×)
```

*Step 3 — Drink Detection:*
```
Validation check:
├─ Carbs ≤ 1.0g? AND
├─ Calories ≤ 15? AND
└─ Protein ≤ 1.0g?

If ALL true → Drink detected
   └─ Return: 1 mg/dL spike (minimal)

If ANY false → Meal detected
   └─ Continue to prediction
```

*Step 4 — Glucose Prediction:*
```
Random Forest Input:
├─ Meal data: [Carbs, Protein, Fibre, Calories]
├─ Patient data: [Age, Weight, Microbiome, History]
    ↓
RF Model
    ↓
Predicted glucose spike: X mg/dL
```

*Step 5 — Explainability Analysis:*
```
SHAP TreeExplainer
├─ Calculate feature contributions
│  ├─ Carbohydrates: +18 mg/dL
│  ├─ Fibre: -5 mg/dL
│  ├─ Protein: +3 mg/dL
│  └─ Other features: ...
    ↓
Generate waterfall plot (PNG)
    ↓
Encode as base64
```

*Step 6 — Clinical Advice:*
```
LLM Prompt:
├─ Food: [name]
├─ Spike: [magnitude]
├─ Macros: [composition]
├─ Microbiome: [profile]
    ↓
Google Gemini API
    ↓
Generate:
├─ Clinical Insight (why this spike)
└─ Action Plan (specific recommendation)
    ↓
Encrypt & Store
├─ SQLite (primary)
└─ JSON cache (secondary)
    ↓
Return JSON response to frontend
```

== A.5 — Technology Stack Summary

| Component | Technology | Purpose |
|-----------|-----------|---------|
| Frontend | React 18, Vite | UI rendering, state management |
| Backend | FastAPI, Uvicorn, Python | API serving, request handling |
| ML Prediction | Scikit-learn (Random Forest) | Glucose spike prediction |
| Explainability | SHAP, Matplotlib | Feature attribution, visualisation |
| Computer Vision | Google Gemini Vision APIs | Food image recognition |
| NLP/LLM | Google Gemini 2.5 Flash | Clinical advice generation |
| Database | SQLite, JSON | Data persistence, caching |
| Security | Fernet (cryptography) | Encryption at rest |
| Environment | Python .venv, npm | Package management |

#pagebreak()

= Appendix B — Initial Project Proposal <appendix-a>

_Attach the initial project proposal form here._

#pagebreak()

= Appendix C — Final Project Proposal <appendix-b>

_Attach the final project proposal form here._

#pagebreak()

= Appendix D — Application for Approval of Research Activities <appendix-c>

_Attach if needed._

#pagebreak()

= Appendix E — Client Consent Form <appendix-d>

_Attach if needed._

#pagebreak()

= Additional Appendices <appendix-extra>

_Add any additional appendices as needed._
