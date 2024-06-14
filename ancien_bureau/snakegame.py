import pygame
import random
import pickle

# Initialisation
pygame.init()

# Dimensions de la fenêtre de jeu
largeur = 800
hauteur = 600

# Couleurs
blanc = (255, 255, 255)
noir = (0, 0, 0)
rouge = (255, 0, 0)

# Création de la fenêtre de jeu
fenetre = pygame.display.set_mode((largeur, hauteur))
pygame.display.set_caption("Jeu de la balle")

# Barre
barre_largeur = 100
barre_hauteur = 20
barre_x = (largeur - barre_largeur) // 2
barre_y = hauteur - barre_hauteur - 10
barre_deplacement = 3

# Balle
balle_rayon = 10
balle_x = random.randint(balle_rayon, largeur - balle_rayon)
balle_y = random.randint(balle_rayon, hauteur - balle_rayon)
balle_deplacement_x = 0.5
balle_deplacement_y = 0.5

# Message de défaite
def afficher_message_defaite(temps, record):
    font = pygame.font.Font(None, 36)
    texte_temps = font.render("Temps écoulé: {} ms".format(temps), True, blanc)
    texte_record = font.render("Record précédent: {} ms".format(record), True, blanc)
    fenetre.blit(texte_temps, ((largeur - texte_temps.get_width()) // 2, (hauteur - texte_temps.get_height()) // 2))
    fenetre.blit(texte_record, ((largeur - texte_record.get_width()) // 2, (hauteur - texte_record.get_height()) // 2 + 50))

# Chargement du record précédent
record = 0
try:
    with open("record.pkl", "rb") as fichier:
        record = pickle.load(fichier)
except FileNotFoundError:
    pass

# Boucle principale du jeu
en_cours = True
debut_jeu = pygame.time.get_ticks()
perdu = False
while en_cours:
    # Gestion des événements
    for evenement in pygame.event.get():
        if evenement.type == pygame.QUIT:
            en_cours = False

    # Déplacement de la barre
    touches = pygame.key.get_pressed()
    if touches[pygame.K_LEFT] and barre_x > 0:
        barre_x -= barre_deplacement
    if touches[pygame.K_RIGHT] and barre_x < largeur - barre_largeur:
        barre_x += barre_deplacement

    # Déplacement de la balle
    balle_x += balle_deplacement_x
    balle_y += balle_deplacement_y

    # Collision de la balle avec la barre
    if balle_y + balle_rayon > barre_y:
        if barre_x - balle_rayon < balle_x < barre_x + barre_largeur + balle_rayon:
            balle_deplacement_y = -balle_deplacement_y
        else:
            perdu = True

    # Collision de la balle avec les bords
    if balle_x - balle_rayon < 0 or balle_x + balle_rayon > largeur:
        balle_deplacement_x = -balle_deplacement_x
    if balle_y - balle_rayon < 0 or balle_y + balle_rayon > hauteur:
        balle_deplacement_y = -balle_deplacement_y

    # Effacement de l'écran
    fenetre.fill(noir)

    # Affichage de la barre
    pygame.draw.rect(fenetre, blanc, (barre_x, barre_y, barre_largeur, barre_hauteur))

    # Affichage de la balle
    pygame.draw.circle(fenetre, rouge, (balle_x, balle_y), balle_rayon)

    # Calcul du temps écoulé
    temps = pygame.time.get_ticks() - debut_jeu

    # Vérification du record
    if temps > record:
        record = temps

    # Si le joueur a perdu, affichage du message de défaite
    if perdu:
        afficher_message_defaite(temps, record)

    # Rafraîchissement de l'écran
    pygame.display.flip()

# Sauvegarde du record
with open("record.pkl", "wb") as fichier:
    pickle.dump(record, fichier)

# Attente de quelques secondes avant de fermer la fenêtre
pygame.time.delay(3000)

# Fermeture du jeu
pygame.quit()
