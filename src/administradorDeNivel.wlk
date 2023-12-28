import wollok.game.*
import configuracion.*
import cabezal.*
import zombies.*
import logoPlanta.*


object administradorMusica{
	var musicaFondo
	
	method iniciarMusicaInicio(){
		musicaFondo = game.sound("sonido/mus_inicio.mp3")
		musicaFondo.volume(0.3)
		musicaFondo.shouldLoop(true)
		musicaFondo.play()
	}
	

	method iniciarMusicaJuego(){
		musicaFondo.stop()
		musicaFondo = game.sound("sonido/mus_juego.mp3")
		musicaFondo.shouldLoop(true)
		musicaFondo.volume(0.3)
		musicaFondo.play()
	}
	
	method pararMusica(){
		musicaFondo.stop()
	}
}


class LogoPrincipal{
	var property position
	var property image
	
}


class AdministradorDeDificultad{
	//Valores que recibe la dificultad normal
	var property solesAlRecolectar = 0
	var property tiempoSpawnZombies = 0
	var property boostDeVidaZombie = 0
	var property boostDeVelocidadZombie = 0
	var property zombiesPosibles = []
	var property tiempoEntreZombies = 0
	var property cantidadDeZombies = 0
	
}

object administradorDeNivel {
	var property indiceDeDificultad = ""
	var property indiceNivelActual = 0
	const logoPrincipal = new LogoPrincipal(position=game.at(2,0), image="pantalla_inicio.png")
	const facil = new AdministradorDeDificultad(solesAlRecolectar=50, tiempoSpawnZombies=13, zombiesPosibles = [new ZombieNormal()], tiempoEntreZombies = 13, cantidadDeZombies =  8)
	const normal = new AdministradorDeDificultad(solesAlRecolectar = 25, tiempoSpawnZombies = 11, boostDeVidaZombie = 0, boostDeVelocidadZombie = 5, zombiesPosibles = [new ZombieNormal(), new ZombieConoDeTransito(),new ZombieBucketHead()], tiempoEntreZombies = 11, cantidadDeZombies = 10)
	const dificil = new AdministradorDeDificultad(solesAlRecolectar = 25, tiempoSpawnZombies = 10, tiempoEntreZombies = 10, boostDeVelocidadZombie = 50, boostDeVidaZombie = 5, cantidadDeZombies = 15, zombiesPosibles = [new ZombieNormal(), new ZombieConoDeTransito(),new ZombieBucketHead(),new ZombieNewsPaper(), new ZombieDoor()])
	const modoAdmin = new AdministradorDeDificultad(solesAlRecolectar = 999, tiempoSpawnZombies = 1, tiempoEntreZombies = 10, cantidadDeZombies = 8, zombiesPosibles = [new ZombieNewsPaper(), new ZombieDoor()])


	method configurarInputs(){
		//Configurar los inputs del administrador de nivel. 
		keyboard.enter().onPressDo{if(indiceNivelActual!=1){self.cargarConfiguracionDeDificultad()}}
		//Ir de pantalla de inicio a pantalla de configuracion de dificultad 
	}
	method cargarNivelPantallaInicio(){
		//Cargar los visuals y fondo del juego
		game.boardGround("fondo.jpg")
		game.addVisual(logoPrincipal)
		indiceNivelActual = 0
		game.schedule(100, {administradorMusica.iniciarMusicaInicio()}) //esto esta en administrador de nivel
		
	}
	
		method cargarConfiguracionDeDificultad(){
		game.clear()
		game.boardGround("fondo.jpg")
		game.addVisual(new LogoPrincipal(position=game.at(2,1), image="pantalla_seleccion.png"))
		indiceNivelActual = 1
		keyboard.num1().onPressDo{if(indiceNivelActual!=2){self.cargarNivelPantallaJuego(facil)}} 
		keyboard.num2().onPressDo{if(indiceNivelActual!=2){self.cargarNivelPantallaJuego(normal)}}
		keyboard.num3().onPressDo{if(indiceNivelActual!=2){self.cargarNivelPantallaJuego(dificil)}}
		keyboard.num4().onPressDo{if(indiceNivelActual!=2){self.cargarNivelPantallaJuego(modoAdmin)}}
	}
	
	
	method cargarNivelPantallaJuego(dificultad){
	//Cargar los visuals de la pantalla de juego (donde plantamos)
		gestorDificultad.dificultadActual(dificultad)
		spawnZombies.reiniciarZombies()
		game.clear()
		game.schedule(100, {administradorMusica.iniciarMusicaJuego()})
		game.addVisualCharacter(cabezal)
		game.addVisual(cabezalDeSeleccion)
		configuracion.agregarTareas()
		configuracion.agregarLogosPlantas()
		indiceNivelActual = 2
		spawnZombies.esperarYComenzarAtaque(gestorDificultad.tiempoSpawnZombies())
	}
	
	method cargarNivelPantallaGameOver(){
		//Cargar los visuals de la pantalla de game over
		game.clear()
		administradorMusica.pararMusica()
		game.addVisual(new LogoPrincipal(position=game.at(2,0), image="pantalla_gameOver.png"))
		indiceNivelActual = 3
		self.configurarInputs()
		indicadorSoles.cantidadSoles(200)
		
	}
	
	method cargarNivelPantallaVictoria(){
		//Cargar los visuals de la pantalla de game over
		game.clear()
		administradorMusica.pararMusica()
		game.addVisual(new LogoPrincipal(position=game.at(2,0), image="pantalla_victoria.png"))
		indiceNivelActual = 4
		self.configurarInputs()
		indicadorSoles.cantidadSoles(200)
		
	}
		
}


object gestorDificultad{
	var property dificultadActual
	method tiempoEntreZombies() = dificultadActual.tiempoEntreZombies()
	method zombiesPosibles() = dificultadActual.zombiesPosibles()
	method solesAlRecolectar() = dificultadActual.solesAlRecolectar()
	method tiempoSpawnZombies() = dificultadActual.tiempoSpawnZombies()
	method boostDeVidaZombie() = dificultadActual.boostDeVidaZombie()
	method boostDeVelocidadZombie() = dificultadActual.boostDeVelocidadZombie()
	method cantidadDeZombies() = dificultadActual.cantidadDeZombies()
}



