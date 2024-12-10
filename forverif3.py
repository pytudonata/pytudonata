import random
import time

def slow_print(text, delay=0.05):
    for char in text:
        print(char, end='', flush=True)
        time.sleep(delay)
    print()

class Player:
    def __init__(self, name):
        self.name = name
        self.health = 100
        self.inventory = []
        self.gold = 0

    def take_damage(self, amount):
        self.health -= amount
        if self.health < 0:
            self.health = 0

    def heal(self, amount):
        self.health += amount
        if self.health > 100:
            self.health = 100

    def add_item(self, item):
        self.inventory.append(item)

    def remove_item(self, item):
        if item in self.inventory:
            self.inventory.remove(item)

    def has_item(self, item):
        return item in self.inventory

    def add_gold(self, amount):
        self.gold += amount

    def spend_gold(self, amount):
        if self.gold >= amount:
            self.gold -= amount
            return True
        return False

class Enemy:
    def __init__(self, name, health, damage):
        self.name = name
        self.health = health
        self.damage = damage

    def take_damage(self, amount):
        self.health -= amount
        if self.health < 0:
            self.health = 0

def battle(player, enemy):
    slow_print(f"A wild {enemy.name} appears!")
    while player.health > 0 and enemy.health > 0:
        slow_print(f"{enemy.name} attacks!")
        player.take_damage(enemy.damage)
        slow_print(f"You took {enemy.damage} damage. Your health: {player.health}")
        if player.health <= 0:
            slow_print(f"{enemy.name} has defeated you...")
            return False

        slow_print(f"You attack {enemy.name}!")
        enemy.take_damage(20)
        slow_print(f"{enemy.name}'s health: {enemy.health}")
        if enemy.health <= 0:
            slow_print(f"You defeated {enemy.name}!")
            return True

def shop(player):
    slow_print("You find a traveling merchant.")
    slow_print("He offers the following items:")
    slow_print("1. Health Potion (20 gold) - Restores 30 health")
    slow_print("2. Iron Sword (50 gold) - Increases attack power")
    slow_print("3. Exit Shop")
    
    while True:
        choice = input("Choose an item to buy (1/2/3): ")
        if choice == "1":
            if player.spend_gold(20):
                player.heal(30)
                slow_print("You drink the Health Potion. Your health is restored.")
            else:
                slow_print("You don't have enough gold.")
        elif choice == "2":
            if player.spend_gold(50):
                player.add_item("Iron Sword")
                slow_print("You purchase the Iron Sword. Your attacks will be stronger.")
            else:
                slow_print("You don't have enough gold.")
        elif choice == "3":
            slow_print("You leave the shop.")
            break
        else:
            slow_print("Invalid choice.")

def random_event(player):
    event = random.choice(["treasure", "trap", "enemy"])
    if event == "treasure":
        gold_found = random.randint(10, 50)
        slow_print(f"You find a hidden treasure chest with {gold_found} gold!")
        player.add_gold(gold_found)
    elif event == "trap":
        damage = random.randint(10, 30)
        slow_print(f"You trigger a trap and take {damage} damage!")
        player.take_damage(damage)
    elif event == "enemy":
        enemy = Enemy("Goblin", 40, 15)
        battle(player, enemy)

def explore(player):
    slow_print("You continue deeper into the forest.")
    while player.health > 0:
        slow_print("You come across a clearing with three paths.")
        slow_print("1. Go left")
        slow_print("2. Go right")
        slow_print("3. Move forward")
        choice = input("Choose a path (1/2/3): ")
        if choice in ["1", "2", "3"]:
            random_event(player)
        else:
            slow_print("You stand still, unsure of where to go.")

        if player.health > 0:
            continue_adventure = input("Do you want to keep exploring? (yes/no): ").lower()
            if continue_adventure == "no":
                break

def final_battle(player):
    slow_print("As you reach the end of the forest, a shadowy figure blocks your path.")
    enemy = Enemy("Dark Sorcerer", 100, 25)
    if battle(player, enemy):
        if player.has_item("Magic Amulet"):
            slow_print("The Magic Amulet glows, dispelling the sorcerer's dark magic!")
            slow_print("You emerge victorious!")
        else:
            slow_print("With great effort, you defeat the Dark Sorcerer!")
    else:
        slow_print("Your journey ends here...")

def start_game():
    slow_print("Welcome to the adventure game!")
    name = input("Enter your name: ")
    player = Player(name)
    slow_print(f"Hello, {player.name}. Your adventure begins now.")

    slow_print("You start in a small village.")
    slow_print("There are rumors of danger in the nearby forest.")
    choice = input("Do you want to enter the forest? (yes/no): ").lower()

    if choice == "yes":
        slow_print("You venture into the forest.")
        random_event(player)
        if player.health > 0:
            shop(player)
            explore(player)
            if player.health > 0:
                final_battle(player)
    else:
        slow_print("You decide to stay in the village. Maybe another day...")

    slow_print("Game over.")

    slow_print("But wait... something feels strange.")
    slow_print("You hear a whisper in the darkness.")

    slow_print("A mysterious portal appears before you.")
    choice = input("Do you step into the portal? (yes/no): ").lower()

    if choice == "yes":
        slow_print("You step into the portal and find yourself in an ancient arena.")
        slow_print("A voice booms: 'Welcome, brave adventurer, to the Trials of Eternity!'")
        slow_print("You see three doors ahead, each glowing with a strange light.")

        while True:
            slow_print("1. Enter the door with red light.")
            slow_print("2. Enter the door with blue light.")
            slow_print("3. Enter the door with green light.")
            door_choice = input("Choose a door (1/2/3): ")

            if door_choice == "1":
                slow_print("You enter the red-lit room and face a fiery elemental!")
                enemy = Enemy("Fire Elemental", 70, 20)
                if battle(player, enemy):
                    slow_print("The elemental drops a glowing ruby. You take it.")
                    player.add_item("Glowing Ruby")
                else:
                    slow_print("The elemental's flames consume you.")
                    break

            elif door_choice == "2":
                slow_print("The blue-lit room is filled with water and a giant serpent.")
                enemy = Enemy("Water Serpent", 80, 15)
                if battle(player, enemy):
                    slow_print("The serpent drops a shimmering sapphire. You take it.")
                    player.add_item("Shimmering Sapphire")
                else:
                    slow_print("The serpent's coils crush you.")
                    break

            elif door_choice == "3":
                slow_print("The green-lit room is a dense jungle with a lurking beast.")
                enemy = Enemy("Jungle Beast", 90, 25)
                if battle(player, enemy):
                    slow_print("The beast leaves behind an emerald. You take it.")
                    player.add_item("Emerald")
                else:
                    slow_print("The beast's claws end your journey.")
                    break
            else:
                slow_print("You hesitate, and the portal begins to close.")

            if player.health > 0:
                slow_print("A booming voice congratulates you: 'You have completed the trial!'")
                slow_print("The portal reopens, leading you back to your village.")
                player.add_gold(100)
                slow_print("You find 100 gold in your pocket as a reward.")
                break
            else:
                slow_print("You collapse from exhaustion. The portal disappears.")
                break
    else:
        slow_print("You decide not to enter the portal and return to your quiet life.")
        slow_print("Years later, the legend of the portal still haunts your dreams.")

    slow_print("Time passes...")
    slow_print("One day, you hear a knock at your door.")

    slow_print("An old man hands you a letter sealed with a royal crest.")
    slow_print("The letter invites you to the King's Court for your heroism.")
    slow_print("You decide to accept the invitation.")
    
    slow_print("At the court, the King greets you warmly.")
    slow_print("'You have proven yourself a true hero,' he says.")
    slow_print("The King offers you three rewards to choose from:")
    slow_print("1. A chest of gold.")
    slow_print("2. A magical weapon.")
    slow_print("3. A noble title.")

    while True:
        reward = input("Choose your reward (1/2/3): ")
        if reward == "1":
            slow_print("You receive a chest filled with gold. You are now very wealthy.")
            player.add_gold(500)
            break
        elif reward == "2":
            slow_print("You receive an enchanted sword that glows with power.")
            player.add_item("Enchanted Sword")
            break
        elif reward == "3":
            slow_print("You are granted the title of Knight and given lands to rule.")
            player.add_item("Noble Title")
            break
        else:
            slow_print("The King awaits your choice patiently.")

    slow_print("Your adventure doesn't end here. Many tales will be told about you.")
    slow_print("You prepare for your next journey...")
    
    while True:
        slow_print("Do you want to:")
        slow_print("1. Retire and enjoy your wealth.")
        slow_print("2. Continue adventuring into new lands.")
        end_choice = input("Choose your fate (1/2): ")
        
        if end_choice == "1":
            slow_print("You settle down in a quiet village and live a peaceful life.")
            slow_print("Years later, your name becomes a legend told by the fireside.")
            break
        elif end_choice == "2":
            slow_print("You gather your gear and set off into the horizon.")
            slow_print("New adventures await, and the world will never forget your name.")
            break
        else:
            slow_print("Your decision is unclear, but time waits for no one.")

    slow_print("As you walk away, the sun sets on the horizon, painting the sky with hues of gold and crimson.")
    slow_print("You reflect on the choices you've made and the battles you've fought.")
    slow_print("Your journey has shaped you, turning you into a legend in your own right.")
    slow_print("The wind whispers your name as if carrying it to the farthest corners of the world.")

    slow_print("A new chapter awaits, but for now, you find peace in the moment.")
    slow_print("You close your eyes and take a deep breath, feeling a rare sense of calm.")
    slow_print("For the first time in what feels like years, you truly relax.")
    slow_print("You realize that adventure is not only about danger and excitement.")

    slow_print("It's about the friends you've made, the challenges you've overcome, and the stories you carry.")
    slow_print("Each step you took has brought you to this moment of triumph and reflection.")

    slow_print("Suddenly, a raven lands nearby, clutching a scroll in its talons.")
    slow_print("The scroll reads: 'The world still needs heroes like you.'")
    slow_print("You smile, knowing that your story is far from over.")
    slow_print("The call of adventure is always near, waiting for those brave enough to answer it.")

    slow_print("With determination in your heart, you rise and take your first step toward the unknown.")
    slow_print("The road ahead is long, but you are ready for whatever comes next.")

    slow_print("And so, the legend of your name echoes across lands, inspiring countless others.")
    slow_print("Your deeds will be remembered, and your spirit will live on forever.")
    slow_print("Thank you for playing. Until we meet again, adventurer.")
    slow_print("The End. Truly this time.")

start_game()
