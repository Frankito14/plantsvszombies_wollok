import wollok.game.*
import plantas.*
import gestores.*
import administradorDeNivel.*
import elementos.*

class Zombie inherits ElementosDelTablero {
	var property id = gestorIds.nuevoId()
	var property salud = 25
	var property velocidad = 800
	var property positionX = 15
	var property positionY = 0.randomUpTo(5).truncate(0)
	var property position = game.at(positionX, positionY)
	var moving = true
	var property nombreZombie
	var property gestorAnimacion = new GestorAnimacion(imagenBase = self.imagenBase(), idanim = id)
	var property damage = 5
	
	method imagenBase() = "zombies/"+nombreZombie+"_f"
	method imagenComiendo() = "zombies/"+nombreZombie+"_comiendo_f"
	method image() = gestorAnimacion.image()
	method refrescarImagen(){gestorAnimacion = new GestorAnimacion(imagenBase = self.imagenBase(), idanim = id)}
	method text() = salud.toString()
	method textColor() = "FFFFFF"

	override method serDesplantado(){self.continuar()}

	method atacar(){
		game.colliders(self).forEach({p => p.recibirAtaque(self)})
	}
	
	method aumentarVida(){
		salud += gestorDificultad.boostDeVidaZombie()
	}
	
	method aumentarVelocidad(){
		velocidad -= gestorDificultad.boostDeVelocidadZombie()
	}
	
	override method serRalentizado(){
		velocidad += (velocidad * 0.4).min(2500)
		game.removeTickEvent("moverZombie" + self.id().toString())
		game.onTick(self.velocidad(), "moverZombie" + self.id().toString(), {self.moverse()})
	}
	
	method moverse() { 
		if (moving) {
			self.avanzarALaIzquierda(1)
			self.perderSiLlegoAlFinal()
		}
	}
	
	
	override method serImpactado(algo) { 
		self.recibirDanio(algo.damage())
		algo.delete()
	}
	
	

	method muerte() {
		if (salud <= 0) {
			game.removeTickEvent("moverZombie" + self.id().toString())
			game.removeTickEvent("zombieAtaque" + self.id().toString() )
			gestorAnimacion.eliminarTick()
			game.removeVisual(self)
		}
	}
	
	override method continuar(){
			moving = true
			gestorAnimacion.eliminarTick()
			gestorAnimacion = new GestorAnimacion(imagenBase = self.imagenBase(), idanim = id)
	}
	
	override method parar(){
		if(moving){
			moving = false
			gestorAnimacion.eliminarTick()
			gestorAnimacion = new GestorAnimacion(imagenBase = self.imagenComiendo(), idanim = id)
		}	
	}
	
	
	method perderSiLlegoAlFinal(){
		if(self.position().x() < 0)
			administradorDeNivel.cargarNivelPantallaGameOver()
	}
	
	method avanzarALaIzquierda(cantidad){
		self.position(position.left(cantidad))
	} 
	
	method puedeSubir() = self.position().y() < 4
	method puedeBajar() = self.position().y() > 1
	

	override method recibirDanio(danio) {
		salud = (salud - danio).max(0)
		self.muerte()
	}
	
	override method explotar(algo){
		algo.explotar()
	}
}

class ZombieNormal inherits Zombie(nombreZombie = "zombieSimple") {
	method nuevoZombie() = new ZombieNormal()
	
}

class ZombieConoDeTransito inherits Zombie(salud = 40, nombreZombie = "zombie_ch"){
	method nuevoZombie() = new ZombieConoDeTransito()
	
	//5% de probabilidad de bajar una casilla al avanzar 
	override method avanzarALaIzquierda(cantidad){
		super(cantidad)
		const n = 1.randomUpTo(21).truncate(0)
		if ((n==5) and self.puedeBajar())
			self.position(position.down(cantidad))
	}
	
}

class ZombieBucketHead inherits Zombie(salud = 50,  nombreZombie = "zombie_bh") {

	method nuevoZombie() = new ZombieBucketHead()
	
	//5% de probabilidad de subir o bajar una casilla al avanzar 
	override method avanzarALaIzquierda(cantidad){
		super(cantidad)
		const n = 1.randomUpTo(41).truncate(0)
		if ((n==5) and self.puedeSubir())
			self.position(position.up(cantidad))
		if ((n==20) and self.puedeBajar())
			self.position(position.down(cantidad))	
	}
}

class ZombieNewsPaper inherits Zombie(salud = 50, nombreZombie ="zombie_nw", velocidad = 850){
	method nuevoZombie() = new ZombieNewsPaper()
	//Cuando el zombie nw tiene 35 o menos vida pierde su diario, se enoja y su velocidad incrementa.
	//Además, cuando este pierde el diario ignora la ralentización del guisante congelado.

	method imagenSinDiario() = "zombies/zombie_nwSinDiario_f"
    method perderDiarioSiTienePocaVida(){
		 if (salud <= 35 and moving){
		 	gestorAnimacion = new GestorAnimacion(imagenBase = self.imagenSinDiario(), idanim = id)
		 	velocidad = 600
			game.onTick(self.velocidad(), "moverZombie" + self.id().toString(), {self.moverse()})
		 }
	}
	override method recibirDanio(danio){
		super(danio)
		self.perderDiarioSiTienePocaVida()
	}

}

class ZombieDoor inherits Zombie(salud = 60, nombreZombie ="zombie_door", velocidad = 2000){
	var property tienePuerta = true
	method nuevoZombie() = new ZombieDoor()
	//method imagenSinPuerta() = "zombies/zombieSimple_f"
	
    method perderPuertaSiTienePocaVida(){
		 if (salud <= 35 and moving){
		 	nombreZombie = "zombieSimple"
		 	tienePuerta = false
		 	gestorAnimacion = new GestorAnimacion(imagenBase = self.imagenBase(), idanim = id)
		 	velocidad = 1000
		 	game.removeTickEvent("moverZombie" + self.id().toString())
			game.onTick(self.velocidad(), "moverZombie" + self.id().toString(), {self.moverse()})
		 }
	}
	
	
	override method recibirDanio(danio) {
		if (self.tienePuerta())
			salud = ((salud - (danio/2)).max(0)).truncate(0)
		else
			salud = (salud - danio).max(0)
		self.perderPuertaSiTienePocaVida()
		self.muerte()
	}

}



object configuracionZombie{
	
	const zombie = new ZombieNormal()
	
	method spawnearZombie() {
			game.addVisual(zombie)
			game.onTick(800, "moverZombie" + zombie.id().toString(), {zombie.moverse()})
			game.onTick(2000, "zombieAtaque" + zombie.id().toString(), {zombie.atacar()})
	}
}

object spawnZombies{
	const listaZombies = []
	var segsEntreZombies = gestorDificultad.tiempoEntreZombies()
	var cantZombies = gestorDificultad.cantidadDeZombies()
	
	
	method esperarYComenzarAtaque(segs){
		game.schedule(segs*1000, { => self.iniciarSpawn() })
	}
	
	method generarListaZombiesRandom(){
		
		(1..cantZombies).forEach{x => listaZombies.add(gestorDificultad.zombiesPosibles().anyOne().nuevoZombie())}
	}
	
	method reiniciarZombies(){
		listaZombies.clear()
		cantZombies = gestorDificultad.cantidadDeZombies()
		segsEntreZombies = gestorDificultad.tiempoEntreZombies()
	}
	
	
	method iniciarSpawn(){
		self.generarListaZombiesRandom()
		game.onTick(segsEntreZombies*1000 , "crearZombie", {self.crearZombie()})
	}
	
	method crearZombie(){
		if (listaZombies.isEmpty()){
			administradorDeNivel.cargarNivelPantallaVictoria()
		}
		else{
			self.ponerZombieEnNivel(listaZombies.first())
			listaZombies.remove(listaZombies.first())
			segsEntreZombies = (segsEntreZombies-0.5).max(5)	
		}
	}
	
	method ponerZombieEnNivel(zombie){
		game.addVisual(zombie)
		zombie.aumentarVida()
		zombie.aumentarVelocidad()
		game.onTick(zombie.velocidad(), "moverZombie" + zombie.id().toString(), {zombie.moverse()})
		game.onTick(2000, "zombieAtaque" + zombie.id().toString(), {zombie.atacar()})
	}
	
	
}
