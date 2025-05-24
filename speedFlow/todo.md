# speed-flow: Flow-field de particules colorées

- [x] Générer une grille de flow-field basée sur du Perlin seedé
  - [x] Afficher la seed à l'écran et dans la console
  - [x] Permettre de changer la seed (touche dédiée)
  - [x] Mode debug : afficher la grille de vecteurs (basse résolution)

- [x] Particules
  - [x] Créer une classe Particle (position, vitesse, couleur)
  - [ ] Dessiner les trails (laisser une trace)
  - [x] Couleur dépendant de la vitesse instantanée (lerp entre 2-3 couleurs)
  - [x] Déplacer et encapsuler les constantes liées aux particules dans Particle.pde

- [ ] Contrôles clavier
  - [ ] Reset (r)
  - [x] Save (s)
  - [x] Debug (d)
  - [x] Nouvelle seed (n)
  - [ ] Changer la palette de couleurs (c)

- [ ] Affichage
  - [x] Afficher la seed et les paramètres à l'écran et/ou sur l'image sauvegardée

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
