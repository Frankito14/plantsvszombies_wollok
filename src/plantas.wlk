import wollok.game.*
import cabezal.*
import logoPlanta.*
import gestores.*
import elementos.*

object pala inherits ElementosDelTablero{
	const property id = 0
	const property costoSoles = 0
	method nuevaPlanta(posicion) = self
	method imagenCabezal() = "imgPlantas/cabezal_pala.png"
	method accionCabezal(){
		cabezal.desplantar()
	}

}

class Planta inherits ElementosDelTablero{
	var property id =gestorIds.nuevoId()
	var property position
	var property salud = 50
	var property nombrePlanta
	var property costoSoles
	
	var property gestorAnimacion = new GestorAnimacion(imagenBase=self.pathImage(), idanim = id)
	method image() = gestorAnimacion.image()
	method imagenCabezal() = "imgPlantas/cabezal_"+nombrePlanta+".png"
	
	method pathImage() = "imgPlantas/"+nombrePlanta+"_f"

	override method serDesplantado(){
		gestorAnimacion.eliminarTick()
		game.removeVisual(self)
	}
	method accionCabezal(){
		cabezal.plantar()
	}

	override method accionar(posicion){
		game.onCollideDo(self, {o => o.parar()})
	}
	override method recibirAtaque(zombie){ //Daño que recibe de los zombies
		salud = salud - zombie.damage()
		if(salud <= 0){
			self.morir()
		}
	}
	method morir(){
		game.colliders(self).forEach({o => o.continuar()})
		self.serDesplantado()
		
	}

}

class Girasol inherits Planta(costoSoles = 50, nombrePlanta = "girasol"){
	
	method nuevaPlanta(posicion) = new Girasol(position = posicion)
	
	override method accionar(posicion){
		super(posicion)
		game.onTick(10000, "generarSoles" + id.toString(), {self.generarSoles()})
	}
	
	method generarSoles(){
			const solCreado = new Sol(position = position, idSol = gestorIds.nuevoId())
			game.addVisual(solCreado)
			solCreado.accionar()
			
	}

	method solesEnLaPosicion() = position.allElements().filter({o => o.esSol()}).size()
	
	override method serDesplantado(){
		super()
		game.removeTickEvent("generarSoles" + id.toString())
	}
	
}

class CerezaExplosiva inherits Planta(costoSoles = 150, nombrePlanta = "cereza"){
	//La cereza explota pasado un determinado tiempo
	const property damage = 500
	method nuevaPlanta(posicion) = new CerezaExplosiva(position = posicion)
	
	override method accionar(posicion){
		super(posicion)
		self.modoExplosion()
	}
	
	method modoExplosion(){
		game.schedule(2500,{self.explotar()})
	}
	
	method explotar(){
		//game.colliders(self).forEach({o => o.recibirDanio(damage)})
		//game.colliders devuelve el objeto que está en la misma posición de la mina este último recibe 9999 de daño.
		self.serDesplantado()
		const posicionAExplotarArriba = game.at(position.x(), position.y()+1)
		const posicionAExplotarAbajo = game.at(position.x(), position.y()-1)
		self.crearExplosionEn_SiSePuede(position)
		self.crearExplosionEn_SiSePuede(posicionAExplotarArriba)
		self.crearExplosionEn_SiSePuede(posicionAExplotarAbajo)
		
	}
	
	method crearExplosionEn_SiSePuede(posicionAExplotar){
		if (posicionAExplotar.y() != 5){ //Posicion donde estan los selectores de planta
		const explosion = new Explosion(position = posicionAExplotar, idExplosion = gestorIds.nuevoId())
		game.addVisual(explosion)
		game.schedule(500,{explosion.destruir()})
		}
	}
	
	
}

class PapaMina inherits Planta(costoSoles = 200, nombrePlanta = "papa"){
	const property damage = 9999
	method nuevaPlanta(posicion) = new PapaMina(position = posicion)
	
	override method accionar(posicion){
		super(posicion)
		self.modoExplosion()
	}
	
	method modoExplosion(){
		game.onCollideDo(self, {z => z.explotar(self)})
	}
	
	method explotar(){
		game.colliders(self).forEach({o => o.recibirDanio(damage)})
		//game.colliders devuelve el objeto que está en la misma posición de la mina este último recibe 9999 de daño.
		self.serDesplantado()
		//La mina desaparece cuando termina su propósito.
		const explosion = new Explosion(position = position, idExplosion = gestorIds.nuevoId())
		game.addVisual(explosion)
		game.schedule(500,{explosion.destruir()})
	}
	
}

class Guisante inherits Planta(costoSoles = 100, nombrePlanta = "guisante"){
	
	method nuevaPlanta(posicion) = new Guisante(position = posicion)
	
	override method serDesplantado(){
		super()
		game.removeTickEvent("disparar" + id.toString())
	}
	
	override method accionar(posicion){
		super(posicion)
		game.onTick(3500,"disparar" +id.toString() ,{self.dispararGuisante(posicion)})
	}
	
	method dispararGuisante(posicion){
		const guisante = new ProyectilGuisante(position = posicion, posicionInicial = posicion, idGuisante = gestorIds.nuevoId())
		game.addVisual(guisante)
		game.onCollideDo(guisante,{objeto => objeto.serImpactado(guisante)})
	}
}

class GuisanteCongelado inherits Guisante(costoSoles = 175, nombrePlanta = "guisanteCongelado"){
	//Hace poco daño pero ralentiza a los enemigos considerablemente
	override method nuevaPlanta(posicion) = new GuisanteCongelado(position = posicion)
	
	override method dispararGuisante(posicion){
		const guisante = new ProyectilGuisanteCongelado(position = posicion, posicionInicial = posicion, idGuisante = gestorIds.nuevoId())
		game.addVisual(guisante)
		game.onCollideDo(guisante,{objeto => objeto.serRalentizado() objeto.serImpactado(guisante)})
	}
}

class GuisanteDoble inherits Guisante(costoSoles = 200, nombrePlanta = "guisanteDoble"){
	
	override method nuevaPlanta(posicion) = new GuisanteDoble(position = posicion)
	
	override method dispararGuisante(posicion){
		const guisante = new ProyectilGuisanteDoble(position = posicion, posicionInicial = posicion, idGuisante = gestorIds.nuevoId())
		game.addVisual(guisante)
		game.onCollideDo(guisante,{objeto => objeto.serImpactado(guisante)})
	}
}

class Nuez inherits Planta(costoSoles = 50, nombrePlanta = "nuez", salud=100){
	
	method nuevaPlanta(posicion) = new Nuez(position = posicion)

}

class NuezGrande inherits Nuez (costoSoles = 125, nombrePlanta = "nuezGrandeNormal", salud= 250){
	
	override method nuevaPlanta(posicion) = new NuezGrande(position = posicion)
	
	override method recibirAtaque(zombie){ //Daño que recibe de los zombies
		salud = salud - zombie.damage()
		self.cambiarImagenSiTienePocaVida()
		if(salud <= 0){
			self.morir()
		}
	}
	
	method cambiarImagenSiTienePocaVida(){
		if (salud < 100)
			nombrePlanta = "nuezGrandeHerida"
	}

}

class Espinas inherits Planta(costoSoles = 100, nombrePlanta = "espinas"){
	
	const property damage = 4
	
	method nuevaPlanta(posicion) = new Espinas(position = posicion)
	
	override method accionar(posicion){
		game.onTick(200,"ataqueEspinas" +id.toString() ,{self.atacar()})
	}
	
	method atacar(){
		game.colliders(self).forEach({o => o.recibirDanio(damage)})
	}
	
	
	override method serDesplantado(){
		super()
		game.removeTickEvent("ataqueEspinas" + id.toString())
	}
	override method recibirAtaque(zombie){}

}

//generados por plantas

class Explosion inherits ElementosDelTablero{
	var property idExplosion = gestorIds.nuevoId()
	var property gestorAnimacion = new GestorAnimacion(imagenBase = "imgPlantas/explosion_f", idanim = idExplosion)
	var property position
	const damage = 9999
	method image() = gestorAnimacion.image()

	override method destruir(){
		game.colliders(self).forEach({o => o.recibirDanio(damage)})
		gestorAnimacion.eliminarTick()
		game.removeVisual(self)
	}
}
class Sol inherits ElementosDelTablero{
	var property idSol = gestorIds.nuevoId()
	var property gestorAnimacion = new GestorAnimacion (imagenBase = "otros/sol_f", idanim = idSol)
	var property position

	method image() = gestorAnimacion.image()

	override method accionar(){
		game.onCollideDo(self, { p => p.recolectar(self)})
	}
	
	override method destruir(){
		gestorAnimacion.eliminarTick()
		game.removeVisual(self)
	}
	
}

class ProyectilGuisanteCongelado inherits ProyectilGuisante{
	override method initialize(){
		super()
		self.damage(5)
		self.imagen("imgPlantas/guisanteCongelado_proyectil.png")
	}
}

class ProyectilGuisanteDoble inherits ProyectilGuisante{
	override method initialize(){
		super()
		self.damage(20)
		self.imagen("imgPlantas/guisanteDoble_proyectil.png")
	}
}

class ProyectilGuisante inherits ElementosDelTablero{
	var property position
	var property posicionInicial
	var property damage = 10
	var property imagen = "imgPlantas/guisante_proyectil.png"  
	const idGuisante = gestorIds.nuevoId()	
	method initialize(){
		game.onTick(250,"movimientoGuisante"+ idGuisante.toString(),{self.moverDerecha()})
	}
	method image() = imagen

	method moverDerecha(){
		if ((position.x() >= posicionInicial.x() +9) || position.x() >= 9 ){
			self.delete()
		}
		else{position = game.at(position.x()+1,position.y())}
	}
	
	method delete(){
		if(game.hasVisual(self)){
			game.removeVisual(self)
			game.removeTickEvent("movimientoGuisante" + idGuisante)
		}
		
		}
	
}

