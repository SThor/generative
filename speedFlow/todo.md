# speed-flow: Flow-field de particules colorées

- [ ] Générer une grille de flow-field basée sur du Perlin seedé
  - [ ] Afficher la seed à l'écran et dans la console
  - [ ] Permettre de changer la seed (touche dédiée)
  - [ ] Mode debug : afficher la grille de vecteurs (basse résolution)

- [ ] Particules
  - [ ] Créer une classe Particle (position, vitesse, couleur)
  - [ ] Dessiner les trails (laisser une trace)
  - [ ] Couleur dépendant de la vitesse instantanée (lerp entre 2-3 couleurs)

- [ ] Contrôles clavier
  - [ ] Reset (r)
  - [ ] Save (s)
  - [ ] Debug (d)
  - [ ] Nouvelle seed (n)
  - [ ] Changer la palette de couleurs (c)

- [ ] Affichage
  - [ ] Afficher la seed et les paramètres à l'écran et/ou sur l'image sauvegardée

- [ ] Optimisation
  - [ ] Tester le nombre de particules possible
  - [ ] (Plus tard) spatial hash/grid si besoin

- [ ] Idées pour éviter le "bunching" des particules
  - [ ] Ajouter un peu de jitter aléatoire
  - [ ] Faire évoluer le flow-field dans le temps (offset Perlin)
  - [ ] (Plus tard) répulsion locale

> Notes :
>
> - Commencer simple (statique, peu de particules), puis complexifier.
> - Les paramètres importants (seed, palette, etc.) doivent être visibles pour pouvoir reproduire une image.
> - Si besoin, écrire un fichier texte à côté de l'image avec les paramètres.
