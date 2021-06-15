
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tereo

<!-- badges: start -->

<!-- badges: end -->

The goal of tereo is to …

## Installation

You can install the released version of tereo from
[CRAN](https://CRAN.R-project.org) with:

``` r
devtools::install_github("lewinfox/tereo")
```

## Example

Create a dictionary instance:

``` r
library(tereo)

dict <- Dictionary$new()

dict
#> Te Reo Māori dictionary
#>    42740 entries
```

The `search()` method returns a list of matching entries.

``` r
res <- dict$search("whakapapa")
#> ℹ 6 results found: `kapeu whakapapa`, `whakapapa`, `whakapapa-kanapirahi`, `whakapapaki`, `whakapapa pounamu` and `whakapaparanga`

res$whakapapa
#> $word
#> [1] "whakapapa"
#> 
#> $entries
#> $entries[[1]]
#> $entries[[1]]$num
#> [1] 1
#> 
#> $entries[[1]]$pos
#> [1] "verb"
#> 
#> $entries[[1]]$definition
#> [1] "(-hia,-tia) to lie flat, lay flat."
#> 
#> $entries[[1]]$example
#> [1] "E kore a Kiki e puta ki waho, engari ka tōia te papa o tōna whare kia tuwhera, ka mate tonu iho te manuhiri, whakapapa tonu te manuhiri i te mate (NM 1928:145). / Kiki would not come out, but when he pulled open the door of his house the visitors fell down dead, they lay out dead."
#> 
#> 
#> $entries[[2]]
#> $entries[[2]]$num
#> [1] 2
#> 
#> $entries[[2]]$pos
#> [1] "verb"
#> 
#> $entries[[2]]$definition
#> [1] "(-hia,-tia) to place in layers, lay one upon another, stack flat."
#> 
#> $entries[[2]]$example
#> [1] "Ka whakapapatia ngā mapi ko ngā mea o Aotearoa ki runga. / The maps were placed one on top of the other with the ones of New Zealand on top."
#> 
#> 
#> $entries[[3]]
#> $entries[[3]]$num
#> [1] 3
#> 
#> $entries[[3]]$pos
#> [1] "verb"
#> 
#> $entries[[3]]$definition
#> [1] "(-hia,-tia) to recite in proper order (e.g. genealogies, legends, months), recite genealogies."
#> 
#> $entries[[3]]$example
#> [1] "Ko te ingoa o te whare, o te marae rānei, o Ngāti Rangi, ko Tāne-nui-a-Rangi kua whakapapatia ake nei e au (HP 1991:6). / The name of the house, or marae, of Ngāti Rangi is Tāne-nui-a-Rangi which I have set out above."
#> 
#> 
#> $entries[[4]]
#> $entries[[4]]$num
#> [1] 4
#> 
#> $entries[[4]]$pos
#> [1] "noun"
#> 
#> $entries[[4]]$definition
#> [1] "genealogy, genealogical table, lineage, descent - reciting whakapapa was, and is, an important skill and reflected the importance of genealogies in Māori society in terms of leadership, land and fishing rights, kinship and status. It is central to all Māori institutions. There are different terms for the types of whakapapa and the different ways of reciting them including: tāhū (recite a direct line of ancestry through only the senior line); whakamoe (recite a genealogy including males and their spouses); taotahi (recite genealogy in a single line of descent); hikohiko (recite genealogy in a selective way by not following a single line of descent); ure tārewa (male line of descent through the first-born male in each generation)."
#> 
#> $entries[[4]]$example
#> [1] "He mea nui ki a tātau ō tātau whakapapa (HP 1991:1). / Our genealogies are important to us. (Te Kākano Textbook (Ed. 2): 3; Te Māhuri Study Guide (Ed. 1): 13-14; Te Kōhure Textbook (Ed. 2): 237-240;)"
```
