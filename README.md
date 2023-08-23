# Projet d'Algo et Complexité (Master 1 - Semestre 1)

## Introduction

### Puissance 4

Le Puissance 4 est un jeu de stratégie combinatoire abstrait, le but du jeu est d’aligner une série de 4 pions de même couleur sur une grille de 6 rangées et 7 colonnes. Chaque joueur dispose de 21 pions d’une couleur (par convention jaune ou rouge).

Pendant la partie, les deux joueurs placent tour à tour un pion dans la colonne de leur choix, le pion coulisse alors jusqu’à la position la plus basse possible dans la dite colonne à la suite de quoi, c’est à l’adversaire de jouer. Le vainqueur est le joueur qui réalise le premier un alignement (horizontal, vertical ou en diagonal) d’au moins quatre pions consécutifs de sa couleur. Toutefois, si quand toutes les cases de la grille de jeu sont remplies, aucun des deux joueurs n’a pu réaliser d’alignement, la partie est déclarée nulle.

### Objectif du projet

L’objectif de ce projet est la réalisation d’un jeu de Puissance 4 qui d’une part devra être écrit avec le langage de programmation Caml, et qui d’autre part devra utiliser un algorithme de Minimax avec élagage alpha-bêta afin de permettre à l’utilisateur de jouer contre l’ordinateur.

## Minimax avec élagage alpha-bêta

### Problème des jeux à deux joueurs

Le fait de faire jouer un ordinateur pose un certain nombre problèmes que beaucoup d’informaticiens cherchent à résoudre depuis bon nombre d’années maintenant, et cela, car selon le jeu, le grand nombre de solutions à analyser pour connaître le meilleur mouvement à faire oblige les chercheurs à trouver et utiliser des méthodes autres que la force brute. On peut par exemple citer les échecs où le nombre de mouvements possibles ne permet pas d’étudier tous les cas de figure.

En supposant que nous puissions explorer la liste complète de tous les mouvements possibles, en prenant comme point de départ une position de jeu légale spécifique. Un tel programme nécessiterait une fonction pour générer des mouvements légaux basés sur une position de départ, ainsi qu’une fonction qui évaluerait un "score" pour chaque position résultante. La fonction d’évaluation doit alors attribuer un score maximum à une position gagnante et un score minimal à une position perdante.

Après avoir choisi une position initiale, on peut ensuite construire un arbre de tous les cas possibles, où chaque nœud correspond à une position et où les feuilles indiquent les résultats gagnants, perdants ou nuls. Une fois que l’arbre est construit, son exploration permettrait de déterminer s’il existe un itinéraire menant à la victoire, ou une position nulle, à défaut. Le chemin le plus court peut alors être choisi pour atteindre le but souhaité.

Comme la taille globale d’un tel arbre est généralement trop grande pour qu’il soit complètement représenté, il est généralement nécessaire de limiter le nombre de branches de l’arbre qui sont construites. Une première stratégie consiste à limiter la ”profondeur” de la recherche, c’est-à-dire le nombre de déplacements et de réponses à évaluer. On réduit ainsi la largeur de l’arbre ainsi que sa hauteur.

### Minimax alpha-bêta

L’algorithme Minimax est un algorithme de recherche en profondeur, toutefois la profondeur maximale de la recherche est limité. Pour fonctionner, il a besoin :
* d’une fonction générant des mouvements légaux à partir d’une position
* d’une fonction pour évaluer une position dans le jeu.

En partant d’une position de jeu initiale, l’algorithme explore tous les mouvements légaux jusqu’à la profondeur demandée. Les scores associés aux feuilles de l’arbre sont calculés à l’aide d’une fonction d’évaluation. Un score positif indique une bonne position pour le joueur A, alors qu’un score négatif indique une mauvaise position pour le joueur A et donc une bonne position pour le joueur B. Chaque joueur essaie de choisir ses coups d’une manière qui lui sera le plus profitable. En recherchant le meilleur coup pour le joueur A, une recherche de profondeur 1 déterminera le coup immédiat qui maximise le score de la nouvelle position.

La recherche à la profondeur 1 est, en règle générale, insuffisante, car elle ne prend pas en compte la réponse possible d’un adversaire. Une telle recherche aboutit à des programmes qui recherchent avidement des gains immédiats sans s’apercevoir que les pièces sont protégées ou que la position est en réalité perdante. Une exploration plus profonde jusqu’à la profondeur 2 permet de percevoir au moins les plus simples contre-mouvements du joueur B.

Dans la plupart des jeux, il est possible d’essayer de confondre l’adversaire, de le forcer à jouer certains mouvements, d’essayer de brouiller les pistes dans l’espoir qu’il fasse une erreur. Une fouille de profondeur 2 est malheureusement inadéquate pour ce genre de tactique. Ce type de stratégie peut rarement être bien exploité par un programme étant donné qu’il n’est pas capable de visualiser l’évolution probable des positions vers la fin de partie. Malheureusement, l’augmentation de la profondeur de recherche prend rapidement la forme d’une "explosion" combinatoire. C’est pour cette raison qu’il faut essayer de limiter la profondeur de la recherche.

L’algorithme Minimax alpha-bêta est une variante plus optimisé de l’algorithme Minimax, où, plutôt que de faire une simple recherche, on ne réalise qu’une exploration partielle de l’arbre,  puisque lors de l’exploration, il n’est pas intéressant d’examiner les sous-arbres qui conduisent à des configurations dont la valeur n’aura de toute façon pas d’impact sur le calcul du gain. Autrement dit, le Minimax avec élagage alphabêta n’évalue pas les nœuds dont on est sûr que leur qualité sera inférieure à un nœud déjà évalué.