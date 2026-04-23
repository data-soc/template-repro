# Template reporte reproducibilidad

Link al reporte [**AQUÍ**](https://data-soc.github.io/template-repro/)

Este repositorio contiene una plantilla para el reporte de reproducibilidad del Trabajo 1 del curso [Investigación Social Abierta](https://cienciasocialabierta.cl/2026/). La plantilla está diseñada para ser clonada y modificada por cada estudiante, siguiendo el protocolo [IPO](https://lisacoes.com/protocolos/a-ipo-rep/) (IInput-Processing-Output) y utilizando el formato Quarto.

![](https://lisacoes.com/protocolos/a-ipo-rep/ipo-hex.png)

## Working tree del proyecto

Este proyecto se organiza de la siguiente manera: 

<!-- WORKING_TREE_START -->
```text
template-repro/
|- index.qmd
|- index.html
|- index.pdf
|- README.md
|- libs/
|  |- ocs.scss
|- input/
|  |- bib/
|  |- data/
|  |  |- original/
|  |  |- proc/
|  |- images/
|  |- original-code/
|- processing/
|  |- prod_analysis.Rmd
|  |- prod_analysis.html
|  |- prod_prep.Rmd
|  |- prod_prep.html
|  |- README-prod.md
|- output/
|  |- graphs/
|  |- tables/
|- index_files/
|- reporte-repro_files/
```

Este working tree se actualiza automaticamente al hacer commit mediante una github action que se encuetra definida en el archivo `.github/workflows/update-working-tree.yml`. El propósito de esta acción es mantener un registro actualizado de la estructura del proyecto, lo que facilita la navegación y organización de los archivos para los estudiantes.


