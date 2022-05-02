//
//  GameScene.swift
//  FlappyFlying
//
//  Created by Orlando Landaeta on 15/4/21.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var varFondo = SKSpriteNode()
    let letTexturaFondo = SKTexture(imageNamed:"fondo.png")
    
    var varMosca = SKSpriteNode()
    let letTexturaMosca2 = SKTexture(imageNamed: "fly1.png"), letTexturaMosca1 = SKTexture(imageNamed: "fly2.png")

    var varTubo1 = SKSpriteNode(), varTubo2 = SKSpriteNode()
    let letTexturaTubo1 = SKTexture(imageNamed: "Tubo1.png"), letTexturaTubo2 = SKTexture(imageNamed: "Tubo2.png")
    
    var varLblPuntos = SKLabelNode()
    var varPuntuacion = 0
    var varLblGameOver = SKLabelNode(text: "")
        
    var varTimer = Timer()
    var varGameOver = false
    
    enum enumTipoNodo : UInt32 {
        case mosca = 1
        case tuboSuelo = 2
        case espacioTubos = 4
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        funcRestartGame()
    }
    
    func funcRestartGame() {
        //Timer Tubos
        varTimer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(self.funcAddTubosEspacios), userInfo: nil, repeats: true)
        //LabelPuntuacion
        funcAddLblPuntos()
        funcAddFondo()
        funcAddMosca()
        funcAddTechoSuelo()
        //TUBOS //ESPACIOS ENTRE TUBOS
        funcAddTubosEspacios()
    }
    
    func funcAddMosca() {
        //MOSCA
        
            //ANIMACION DE LA MOSCA
        let letAnimacion = SKAction.animate(with: [letTexturaMosca1, letTexturaMosca2], timePerFrame: 0.05)
        let letAnimacionInfinita = SKAction.repeatForever(letAnimacion)
        
            //POSICION DE LA MOSCA
        varMosca = SKSpriteNode(texture: letTexturaMosca1)
        varMosca.position = CGPoint(x: self.frame.midX - self.size.width / 4, y: self.frame.midY)
        varMosca.physicsBody = SKPhysicsBody.init(circleOfRadius: letTexturaMosca1.size().height / 2)
        varMosca.physicsBody!.isDynamic = false
        varMosca.physicsBody!.categoryBitMask = enumTipoNodo.mosca.rawValue
        varMosca.physicsBody!.collisionBitMask = enumTipoNodo.tuboSuelo.rawValue
        varMosca.physicsBody!.contactTestBitMask = enumTipoNodo.tuboSuelo.rawValue | enumTipoNodo.espacioTubos.rawValue
        
        varMosca.run(letAnimacionInfinita)
        varMosca.zPosition = 1
        
        self.addChild(varMosca)
    }
    
    func funcAddFondo() {
        //FONDO
        let letMovimientoFondo = SKAction.move(by: CGVector(dx: -letTexturaFondo.size().width, dy:0), duration:4)
        let letMovimientoFondoOrigen = SKAction.move(by: CGVector(dx: letTexturaFondo.size().width, dy:0), duration:0)
        let letMovimientoInfinitoFondo = SKAction.repeatForever(SKAction.sequence([letMovimientoFondo,letMovimientoFondoOrigen]))
        
        var varI:CGFloat = 0
        while varI < 2 {
            varFondo = SKSpriteNode(texture:letTexturaFondo)
            varFondo.position = CGPoint(x:letTexturaFondo.size().width * varI, y: self.frame.midY)
            varFondo.size.height = self.frame.height
            varFondo.zPosition = -1
            varFondo.run(letMovimientoInfinitoFondo)
            self.addChild(varFondo)
            varI += 1
        }
    }
    
    @objc func funcAddTubosEspacios() {
        
        //ESPACIO ENTRE LOS TUBOS PARA LA DIFICULTAD
        let letGapDificultad = varMosca.size.height * 2.5
        //RANDOM ENTRE CERO Y LA MITAD DEL ALTO DE LA PANTALLA
        let letCantMovimientoRandom = CGFloat(arc4random() % UInt32(self.frame.height / 2))
        //COMPENSACION PARA EVITAR QUE ALGUN TUBO DESAPAREZCA
        let letCompensacionTubos = letCantMovimientoRandom - self.frame.height / 4
        //MOVER TUBOS
        let letMoverTubos = SKAction.move(by: CGVector(dx: -3 * self.frame.width, dy: 0), duration: TimeInterval(self.frame.width / 80))
        //REMOVER TUBOS - ELIMINAR LOS TUBOS AL DESAPARECER DE LA PANTALLA PARA AHORRAR MEMORIA
        let letRemoveTubos = SKAction.removeFromParent()
        //MOVER Y REMOVER TUBO - PARA EJECUTARLO EN CADA TUBO
        let letMoverRemoverTubos = SKAction.sequence([letMoverTubos, letRemoveTubos])
        
        //POSICION DEL TUBO1
        varTubo1 = SKSpriteNode(texture: letTexturaTubo1)
        varTubo1.position = CGPoint(x:self.frame.midX + self.frame.width, y:self.frame.midY + letTexturaTubo1.size().height / 2 + letGapDificultad + letCompensacionTubos)
        varTubo1.zPosition = 0
        varTubo1.run(letMoverRemoverTubos)
        
        varTubo1.physicsBody = SKPhysicsBody(rectangleOf: letTexturaTubo1.size())
        varTubo1.physicsBody!.isDynamic = false
        varTubo1.physicsBody!.categoryBitMask = enumTipoNodo.tuboSuelo.rawValue
        varTubo1.physicsBody!.collisionBitMask = enumTipoNodo.mosca.rawValue
        varTubo1.physicsBody!.contactTestBitMask = enumTipoNodo.mosca.rawValue
    
        self.addChild(varTubo1)
        
        //POSICION DEL TUBO2
        varTubo2 = SKSpriteNode(texture: letTexturaTubo2)
        varTubo2.position = CGPoint(x:self.frame.midX  + self.frame.width, y:self.frame.midY - letTexturaTubo2.size().height / 2 - letGapDificultad + letCompensacionTubos)
        varTubo2.zPosition = 0
        varTubo2.run(letMoverRemoverTubos)
        
        varTubo2.physicsBody = SKPhysicsBody(rectangleOf: letTexturaTubo1.size())
        varTubo2.physicsBody!.isDynamic = false
        varTubo2.physicsBody!.categoryBitMask = enumTipoNodo.tuboSuelo.rawValue
        varTubo2.physicsBody!.collisionBitMask = enumTipoNodo.mosca.rawValue
        varTubo2.physicsBody!.contactTestBitMask = enumTipoNodo.mosca.rawValue

        self.addChild(varTubo2)
        
        //ESPACIO ENTRE LOS TUBOS
        
        //IMAGEN TEMPORAL PARA RECONOCER EL ESPACIO
//        let letImgPoop = SKTexture(imageNamed: "poop.jpg")
//        let letEspacio = SKSpriteNode( texture: letImgPoop)
    
        let letEspacio = SKSpriteNode()
        letEspacio.position = CGPoint(x: self.frame.midX + self.frame.width + letTexturaTubo1.size().width * 0.65, y: 0)
        letEspacio.size.width = 1
        letEspacio.size.height = self.frame.height
        
        letEspacio.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 0.2, height: self.frame.height))
        letEspacio.physicsBody!.isDynamic = false
        letEspacio.physicsBody!.categoryBitMask = enumTipoNodo.espacioTubos.rawValue
        letEspacio.physicsBody!.collisionBitMask = 0
        letEspacio.physicsBody!.contactTestBitMask = enumTipoNodo.mosca.rawValue
        
        letEspacio.zPosition = 1
        letEspacio.run(letMoverRemoverTubos)
        
        self.addChild(letEspacio)

    }
    
    func funcAddTechoSuelo(){
        //TECHO - LIMITE SUPERIOR PARA QUE LA MOSCA NO SALGA DE LA PANTALLA
        let letTecho = SKNode()
        letTecho.position = CGPoint(x: self.frame.midX, y: (self.frame.height / 2) - 20)
        letTecho.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        letTecho.physicsBody!.isDynamic = false
        self.addChild(letTecho)
        
        //SUELO - LIMITE INFERIOR PARA QUE LA MOSCA NO SALGA DE LA PANTALLA
        let letSuelo = SKNode()
        letSuelo.position = CGPoint(x: -self.frame.midX, y: (-self.frame.height / 2) + 10)
        letSuelo.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        letSuelo.physicsBody!.isDynamic = false
        letSuelo.physicsBody!.categoryBitMask = enumTipoNodo.tuboSuelo.rawValue
        letSuelo.physicsBody!.collisionBitMask = enumTipoNodo.mosca.rawValue
        letSuelo.physicsBody!.contactTestBitMask = enumTipoNodo.mosca.rawValue
        self.addChild(letSuelo)
    }
    
//    func touchUp(atPoint pos : CGPoint) {
//
//    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if varGameOver == false {
            //GRAVEDAD DEL CUERPO FISICO DE LA MOSCA
        varMosca.physicsBody!.isDynamic = true
            //VELOCIDAD DEL CUERPO FISICO
        varMosca.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            //IMPULSO AL TOCAR LA PANTALLA
        varMosca.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 80))
        } else {
            varGameOver = false
            varPuntuacion = 0
            self.speed = 1
            self.removeAllChildren()
            funcRestartGame()
        }
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        //detectar contactos entre cuerpos
        
        let letCuerpoA = contact.bodyA
        let letCuerpoB = contact.bodyB
        
        if (letCuerpoA.categoryBitMask == enumTipoNodo.mosca.rawValue && letCuerpoB.categoryBitMask == enumTipoNodo.espacioTubos.rawValue) ||
            (letCuerpoA.categoryBitMask == enumTipoNodo.espacioTubos.rawValue && letCuerpoB.categoryBitMask == enumTipoNodo.mosca.rawValue) {
            
            if varGameOver == false {
            varPuntuacion += 1
            varLblPuntos.text = String(varPuntuacion)
            }
                
        } else {
            
            varGameOver = true
            self.speed = 0
            varTimer.invalidate()
            funcLblGameOver()
        }
        
    }
    
    func funcAddLblPuntos() {
        varLblPuntos.fontName = "04B_19"
        varLblPuntos.fontSize = 80
        varLblPuntos.text = "0"

        varLblPuntos.position = CGPoint(x: 0 - self.frame.width / 3, y: 0 + self.frame.height / 2.5)
        varLblPuntos.zPosition = 2
        self.addChild(varLblPuntos)
    }
    
    func funcLblGameOver() {
        varLblGameOver = SKLabelNode(text: "GAME OVER")
        varLblGameOver.fontName = "04B_19"
        varLblGameOver.fontSize = 80
        varLblGameOver.fontColor = UIColor.black
        varLblGameOver.position = CGPoint(x: self.frame.midX , y: self.frame.midY)
        varLblGameOver.zPosition = 2
        self.addChild(varLblGameOver)
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}


/* La propiedad categoryBitMask es un número que define el tipo de objeto que el cuerpo fisico del nodo tendrá y es considerado para las colisiones y contactos.
     
    La propiedad collisionBitMask es un número que define con cuales categorias de objetos este nodo deberia colisionar.
    
    La propiedad contactTestBitMask es un número que define cuales colisiones nos seran notificadas.
    
    Nota:
     
     Si le das a un nodo numero de Collision Bitmask pero no les das numeros de contact test Bitmask, significa que los nodos podran colisionar pero no tendras manera de saber cuando ocurrio en código (no se notificara al sistema).
     
     Si haces lo contrario (no Collision Bitmask pero si Contact Test Bitmask), no "chocaran" o colisionaran, pero el sistema te podra notificar el momento en que tuvieron contacto.
         
     Si a las dos propiedades les das valores entonces notificado y a su vez los nodos podran colisionar.
     
     Automaticamente los cuerpos fisicos tienen su propiedad de Collision Bitmask = a TODO y su Contact Bitmask = Nada */
