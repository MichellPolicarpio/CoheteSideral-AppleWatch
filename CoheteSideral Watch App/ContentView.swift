//
//  ContentView.swift
//  CoheteSideral Watch App
//
//  Created by Michell Alexis Policarpio Moran on 4/16/25.
//

import SwiftUI
import WatchKit
import AVFoundation

struct ContentView: View {
    @State private var historialPuntuaciones: [Int] = []
    
    var body: some View {
        MenuPrincipalView(historialPuntuaciones: $historialPuntuaciones)
    }
}

struct MenuPrincipalView: View {
    @Binding var historialPuntuaciones: [Int]
    @State private var seleccion: Int? = nil
    
    var body: some View {
        ZStack {
            // Fondo espacial
            EspacioFondo()
            
            ScrollView {
                VStack(spacing: 5) {
                    // Logo del juego
                    VStack(spacing: 0) {
                        Text("COHETE")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.yellow)
                        
                        Text("SIDERAL")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.orange)
                            .padding(.bottom, 5)
                        
                        ZStack {
                            Circle()
                                .fill(Color.indigo.opacity(0.3))
                                .frame(width: 50, height: 50)
                            
                            CohetePixelArt(animacionLlama: true, puedeDisparar: false)
                                .frame(width: 25, height: 35)
                                .rotationEffect(.degrees(-45))
                        }
                        .padding(.bottom, 10)
                    }
                    
                    // Botones del menú
                    VStack(spacing: 10) {
                        BotonMenu(icono: "play.fill", texto: "JUGAR", color: .green) {
                            seleccion = 1
                        }
                        
                        BotonMenu(icono: "trophy.fill", texto: "RÉCORDS", color: .yellow) {
                            seleccion = 2
                        }
                        
                        BotonMenu(icono: "questionmark.circle.fill", texto: "AYUDA", color: .blue) {
                            seleccion = 3
                        }
                        
                        BotonMenu(icono: "info.circle.fill", texto: "ACERCA DE", color: .purple) {
                            seleccion = 4
                        }
                    }
                }
                .padding(.top, 5)
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(item: Binding<Item?>(
            get: { seleccion.map { Item(id: $0) } },
            set: { seleccion = $0?.id }
        )) { item in
            switch item.id {
            case 1:
                GameView(historialPuntuaciones: $historialPuntuaciones)
            case 2:
                HistorialView(historialPuntuaciones: historialPuntuaciones)
            case 3:
                AyudaView()
            case 4:
                AcercaDeView()
            default:
                EmptyView()
            }
        }
    }
    
    struct Item: Identifiable {
        let id: Int
    }
}

struct BotonMenu: View {
    let icono: String
    let texto: String
    let color: Color
    let accion: () -> Void
    
    var body: some View {
        Button(action: accion) {
            HStack(spacing: 15) {
                Image(systemName: icono)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                
                Text(texto)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.8))
                    .shadow(color: color.opacity(0.5), radius: 3, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 10)
    }
}

struct EspacioFondo: View {
    @State private var estrellasPequenas = (0..<30).map { _ in EstrellaPequena() }
    @State private var estrellasGrandes = (0..<5).map { _ in EstrellaGrande() }
    
    var body: some View {
        ZStack {
            // Fondo negro del espacio
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Gradiente de fondo
            RadialGradient(
                gradient: Gradient(colors: [Color.indigo.opacity(0.3), Color.black]),
                center: .center,
                startRadius: 5,
                endRadius: 150
            )
            .edgesIgnoringSafeArea(.all)
            
            // Estrellas pequeñas
            ForEach(0..<estrellasPequenas.count, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(estrellasPequenas[i].opacidad))
                    .frame(width: estrellasPequenas[i].tamano, height: estrellasPequenas[i].tamano)
                    .position(estrellasPequenas[i].posicion)
            }
            
            // Estrellas grandes
            ForEach(0..<estrellasGrandes.count, id: \.self) { i in
                Circle()
                    .fill(Color.white)
                    .frame(width: estrellasGrandes[i].tamano, height: estrellasGrandes[i].tamano)
                    .position(estrellasGrandes[i].posicion)
                    .blur(radius: 0.5)
            }
        }
    }
    
    struct EstrellaPequena {
        let posicion: CGPoint
        let tamano: CGFloat
        let opacidad: Double
        
        init() {
            let screenWidth = WKInterfaceDevice.current().screenBounds.width
            let screenHeight = WKInterfaceDevice.current().screenBounds.height
            self.posicion = CGPoint(
                x: CGFloat.random(in: 0...screenWidth),
                y: CGFloat.random(in: 0...screenHeight)
            )
            self.tamano = CGFloat.random(in: 1...2)
            self.opacidad = Double.random(in: 0.5...1.0)
        }
    }
    
    struct EstrellaGrande {
        let posicion: CGPoint
        let tamano: CGFloat
        
        init() {
            let screenWidth = WKInterfaceDevice.current().screenBounds.width
            let screenHeight = WKInterfaceDevice.current().screenBounds.height
            self.posicion = CGPoint(
                x: CGFloat.random(in: 0...screenWidth),
                y: CGFloat.random(in: 0...screenHeight)
            )
            self.tamano = CGFloat.random(in: 2...3)
        }
    }
}

struct HistorialView: View {
    @Environment(\.dismiss) private var dismiss
    let historialPuntuaciones: [Int]
    
    var body: some View {
        ZStack {
            EspacioFondo()
            
            VStack(spacing: 15) {
                Text("RÉCORDS")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.yellow)
                    .padding(.top, 10)
                
                if historialPuntuaciones.isEmpty {
                    Text("Aún no hay puntuaciones")
                        .foregroundColor(.gray)
                        .padding(.top, 20)
                } else {
                    ForEach(0..<min(5, historialPuntuaciones.count), id: \.self) { index in
                        HStack {
                            Text("\(index + 1)")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(medallaColor(index: index))
                                .frame(width: 30)
                            
                            Spacer()
                            
                            Text("\(historialPuntuaciones[index])")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 5)
                        .background(Color.indigo.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.horizontal, 10)
                    }
                }
                
                Spacer()
                
                Button("Volver") {
                    dismiss()
                }
                .font(.system(size: 16, weight: .medium))
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(Color.blue.opacity(0.8))
                .cornerRadius(10)
                .foregroundColor(.white)
                .padding(.bottom, 10)
            }
        }
        .navigationBarHidden(true)
    }
    
    func medallaColor(index: Int) -> Color {
        switch index {
        case 0: return .yellow    // Oro
        case 1: return .gray      // Plata
        case 2: return .orange    // Bronce
        default: return .white
        }
    }
}

struct AyudaView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            EspacioFondo()
            
            ScrollView {
                VStack(spacing: 15) {
                    Text("CÓMO JUGAR")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.yellow)
                        .padding(.top, 10)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        // Objetivo del juego
                        SeccionAyuda(titulo: "OBJETIVO", icono: "target") {
                            Text("• Alcanza 10,000 puntos")
                            Text("• Esquiva los meteoritos")
                            Text("• Destruye meteoritos con disparos")
                        }
                        
                        // Controles básicos
                        SeccionAyuda(titulo: "CONTROLES", icono: "hand.raised.fill") {
                            InstruccionItem(icono: "dial", texto: "Corona digital: mover cohete")
                            InstruccionItem(icono: "hand.tap", texto: "Tocar izquierda/derecha")
                            InstruccionItem(icono: "hand.draw", texto: "Deslizar a los lados")
                        }
                        
                        // Sistema de disparo
                        SeccionAyuda(titulo: "SISTEMA DE DISPARO", icono: "bolt.fill") {
                            Text("• Evade 7 meteoritos para desbloquear")
                            Text("• Toca el centro para disparar")
                            Text("• Destruye meteoritos para puntos extra")
                        }
                        
                        // Sistema de puntos
                        SeccionAyuda(titulo: "PUNTUACIÓN", icono: "star.fill") {
                            Text("• +10 puntos por segundo")
                            Text("• +100 puntos por evadir")
                            Text("• +50 puntos por destruir")
                        }
                        
                        // Consejos
                        SeccionAyuda(titulo: "CONSEJOS", icono: "lightbulb.fill") {
                            Text("• La velocidad aumenta después de 5,000 puntos")
                            Text("• Mantén un ritmo constante")
                            Text("• Usa los disparos estratégicamente")
                        }
                    }
                    .padding()
                    .background(Color.indigo.opacity(0.2))
                    .cornerRadius(15)
                    .padding(.horizontal, 5)
                    
                    Spacer()
                    
                    Button("Volver") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(Color.blue.opacity(0.8))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .padding(.bottom, 10)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct SeccionAyuda<Content: View>: View {
    let titulo: String
    let icono: String
    let content: Content
    
    init(titulo: String, icono: String, @ViewBuilder content: () -> Content) {
        self.titulo = titulo
        self.icono = icono
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icono)
                    .foregroundColor(.yellow)
                Text(titulo)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.orange)
            }
            
            content
                .font(.system(size: 14))
                .foregroundColor(.white)
                .padding(.leading, 25)
        }
        .padding(.vertical, 5)
    }
}

struct InstruccionItem: View {
    let icono: String
    let texto: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icono)
                .foregroundColor(.yellow)
                .frame(width: 25)
            
            Text(texto)
                .font(.system(size: 14))
                .foregroundColor(.white)
            
            Spacer()
        }
    }
}

struct AcercaDeView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            EspacioFondo()
            
            ScrollView {
                VStack(spacing: 12) {
                    // Título
                    Text("ACERCA DE")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.yellow)
                        .padding(.top, 5)
                    
                    // Contenido principal
                    VStack(spacing: 8) {
                        // Icono y nombre
                        VStack(spacing: 4) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                            
                            Text("Desarrollado por")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            
                            Text("Michell Alexis")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Policarpio Moran")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.vertical, 5)
                        
                        // Información de versión
                        VStack(spacing: 3) {
                            Text("Versión 1.0")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            
                            Text("© 2025")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 3)
                    }
                    .padding(.horizontal, 10)
                    .background(Color.indigo.opacity(0.2))
                    .cornerRadius(15)
                    .padding(.horizontal, 5)
                    
                    // Botón de volver
                    Button(action: { dismiss() }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14))
                            Text("VOLVER")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 15)
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.top, 5)
                    .padding(.bottom, 10)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

// Sistema de Audio y Haptics
class AudioManager {
    static let shared = AudioManager()
    private var isSoundEnabled = true
    
    private init() {}
    
    func playSystemSound(_ type: WKHapticType) {
        guard isSoundEnabled else { return }
        WKInterfaceDevice.current().play(type)
    }
    
    func toggleSound() {
        isSoundEnabled.toggle()
    }
}

// Extensión para efectos hápticos
extension WKInterfaceDevice {
    func playHaptic(_ type: WKHapticType) {
        play(type)
    }
}

struct GameView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var historialPuntuaciones: [Int]
    
    // Estados del juego
    @State private var posicionCohete: CGFloat = 1
    @State private var meteoritos: [Meteorito] = []
    @State private var disparos: [Disparo] = []
    @State private var timer: Timer? = nil
    @State private var gameOver = false
    @State private var puntuacion = 0
    @State private var velocidadJuego = 1.0
    @State private var ultimoTiempo = Date()
    @State private var animacionLlama = false
    @State private var meteoritosEvadidos = 0
    @State private var puedeDisparar = false
    @State private var ultimoDisparo = Date()
    @State private var mostrarAvisoDisparo = false
    @State private var opacidadAviso: Double = 0
    
    // Constantes del juego
    let meteoritosParaDisparo = 7
    let tiempoEntreDisparos: TimeInterval = 0.5
    let puntosPorEvasion = 100
    let puntosPorDisparo = 50
    let puntuacionMaxima = 10000
    let puntuacionAceleracion = 5000
    
    // Constantes para el posicionamiento
    let posicionesX: [CGFloat] = {
        let screenWidth = WKInterfaceDevice.current().screenBounds.width
        let carrilWidth = screenWidth / 3
        return [
            carrilWidth/2,           // Carril izquierdo
            screenWidth/2,           // Carril central
            screenWidth - carrilWidth/2  // Carril derecho
        ]
    }()
    
    // Obtener dimensiones de la pantalla en WatchOS
    var anchoPantalla: CGFloat {
        WKInterfaceDevice.current().screenBounds.width
    }
    
    var altoPantalla: CGFloat {
        WKInterfaceDevice.current().screenBounds.height
    }
    
    var anchoCarril: CGFloat {
        anchoPantalla / 3
    }
    
    var body: some View {
        ZStack {
            // Fondo
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Estrellas (decoración)
            ForEach(0..<20) { index in
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 2, height: 2)
                    .position(
                        x: CGFloat.random(in: 0...anchoPantalla),
                        y: CGFloat.random(in: 0...altoPantalla)
                    )
                    .id("estrella\(index)")
            }
            
            // Elementos de juego
            ElementosJuegoView(
                posicionCohete: posicionCohete,
                meteoritos: meteoritos,
                disparos: disparos,
                puntuacion: puntuacion,
                posicionesX: posicionesX,
                altoPantalla: altoPantalla,
                anchoPantalla: anchoPantalla,
                animacionLlama: animacionLlama,
                puedeDisparar: puedeDisparar
            )
            
            // Aviso de disparo desbloqueado
            if mostrarAvisoDisparo {
                VStack(spacing: 4) {
                    Text("¡DISPARO DESBLOQUEADO!")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.yellow)
                    
                    Text("Toca el centro para disparar")
                        .font(.system(size: 10))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.7))
                .cornerRadius(8)
                .position(x: anchoPantalla/2, y: altoPantalla/3)
                .opacity(opacidadAviso)
            }
            
            if !gameOver {
                // Área de control táctil mejorada
                HStack(spacing: 0) {
                    // Área izquierda
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            moverCohete(direccion: .izquierda)
                        }
                    
                    // Área central (para disparar)
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            disparar()
                        }
                    
                    // Área derecha
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            moverCohete(direccion: .derecha)
                        }
                }
            }
            
            if gameOver {
                GameOverView(
                    puntuacion: puntuacion,
                    onReiniciar: {
                        gameOver = false
                        reiniciarJuego()
                    },
                    onMenu: { dismiss() }
                )
            }
        }
        .edgesIgnoringSafeArea(.all)
        .focusable(true)
        .digitalCrownRotation($posicionCohete, from: 0, through: 2, by: 1, sensitivity: .medium)
        .gesture(
            DragGesture(minimumDistance: 5)
                .onEnded { value in
                    if !gameOver {
                        if value.translation.width < -10 {
                            moverCohete(direccion: .izquierda)
                        } else if value.translation.width > 10 {
                            moverCohete(direccion: .derecha)
                        }
                    }
                }
        )
        .navigationBarHidden(true)
        .onAppear {
            iniciarJuego()
            withAnimation(Animation.easeInOut(duration: 0.3).repeatForever()) {
                animacionLlama.toggle()
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    // MARK: - Subvistas
    
    struct FondoView: View {
        var body: some View {
            Color.black.edgesIgnoringSafeArea(.all)
        }
    }
    
    struct EstrellasView: View {
        var body: some View {
            ForEach(0..<20) { index in
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 2, height: 2)
                    .position(
                        x: CGFloat.random(in: 0...WKInterfaceDevice.current().screenBounds.width),
                        y: CGFloat.random(in: 0...WKInterfaceDevice.current().screenBounds.height)
                    )
                    .id("estrella\(index)")
            }
        }
    }
    
    struct ElementosJuegoView: View {
        let posicionCohete: CGFloat
        let meteoritos: [Meteorito]
        let disparos: [Disparo]
        let puntuacion: Int
        let posicionesX: [CGFloat]
        let altoPantalla: CGFloat
        let anchoPantalla: CGFloat
        let animacionLlama: Bool
        let puedeDisparar: Bool
        
        var body: some View {
            Group {
                // Carril guía
                ForEach(0..<3) { carril in
                    Rectangle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        .frame(width: anchoPantalla/3, height: altoPantalla)
                        .position(x: CGFloat(carril) * anchoPantalla/3 + anchoPantalla/6, 
                                 y: altoPantalla/2)
                }
                
                // Cohete
                CohetePixelArt(animacionLlama: animacionLlama, puedeDisparar: puedeDisparar)
                    .frame(width: 20, height: 35)
                    .position(
                        x: posicionesX[Int(posicionCohete)], 
                        y: altoPantalla - 35
                    )
                
                // Meteoritos
                ForEach(meteoritos) { meteorito in
                    MeteoritoPixelArt()
                        .frame(width: 18, height: 18)
                        .position(x: posicionesX[meteorito.carril], y: meteorito.y)
                }
                
                // Disparos
                ForEach(disparos) { disparo in
                    Rectangle()
                        .fill(Color.yellow)
                        .frame(width: 4, height: 8)
                        .position(x: posicionesX[disparo.carril], y: disparo.y)
                }
                
                // Puntuación
                Text("Puntos: \(puntuacion)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .position(x: anchoPantalla/2, y: 20)
            }
        }
    }
    
    struct ControlesView: View {
        @Binding var posicionCohete: CGFloat
        let producirHaptico: () -> Void
        
        var body: some View {
            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if posicionCohete > 0 {
                            posicionCohete -= 1
                            producirHaptico()
                        }
                    }
                
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if posicionCohete < 2 {
                            posicionCohete += 1
                            producirHaptico()
                        }
                    }
            }
        }
    }
    
    struct GameOverView: View {
        let puntuacion: Int
        let onReiniciar: () -> Void
        let onMenu: () -> Void
        
        var body: some View {
            VStack(spacing: 15) {
                if puntuacion >= 10000 {
                    Text("¡VICTORIA!")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.green)
                } else {
                    Text("¡GAME OVER!")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.red)
                }
                
                Text("Puntuación: \(puntuacion)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                HStack(spacing: 15) {
                    Button(action: onReiniciar) {
                        VStack {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 16))
                            Text("Reiniciar")
                                .font(.system(size: 12))
                        }
                        .padding(10)
                        .frame(minWidth: 80)
                        .background(Color.green.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    Button(action: onMenu) {
                        VStack {
                            Image(systemName: "house.fill")
                                .font(.system(size: 16))
                            Text("Menú")
                                .font(.system(size: 12))
                        }
                        .padding(10)
                        .frame(minWidth: 80)
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
            }
            .padding(15)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                    )
            )
        }
    }
    
    func iniciarJuego() {
        // Asegurarse de limpiar el timer anterior
        timer?.invalidate()
        
        // Reiniciar variables de juego
        meteoritos = []
        posicionCohete = 1
        puntuacion = 0
        gameOver = false
        velocidadJuego = 1.0
        ultimoTiempo = Date()
        meteoritosEvadidos = 0
        puedeDisparar = false
        ultimoDisparo = Date()
        
        // Iniciar nuevo timer
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            actualizarJuego()
        }
        
        // Iniciar sonido de inicio
        AudioManager.shared.playSystemSound(.start)
    }
    
    func reiniciarJuego() {
        iniciarJuego()
        mostrarAvisoDisparo = false
        opacidadAviso = 0
    }
    
    func actualizarJuego() {
        if gameOver { return }
        
        // Actualizar puntuación basada en tiempo
        let tiempoActual = Date()
        let tiempoTranscurrido = tiempoActual.timeIntervalSince(ultimoTiempo)
        ultimoTiempo = tiempoActual
        puntuacion += Int(tiempoTranscurrido * 10)
        
        // Aumentar dificultad con el tiempo solo después de 5000 puntos
        if puntuacion >= puntuacionAceleracion {
            velocidadJuego = min(3.0, 1.0 + Double(puntuacion - puntuacionAceleracion) / 1000.0)
        } else {
            velocidadJuego = 1.0
        }
        
        // Crear nuevos meteoritos
        if Int.random(in: 0...100) < 3 {
            let nuevoMeteorito = Meteorito(id: UUID().uuidString, carril: Int.random(in: 0...2), y: -20)
            meteoritos.append(nuevoMeteorito)
        }
        
        // Mover meteoritos
        for i in 0..<meteoritos.count {
            meteoritos[i].y += 5 * velocidadJuego
        }
        
        // Mover disparos
        for i in 0..<disparos.count {
            disparos[i].y -= 8 * velocidadJuego
        }
        
        // Verificar colisiones con meteoritos
        for meteorito in meteoritos {
            if abs(meteorito.y - (altoPantalla - 35)) < 18 && meteorito.carril == Int(posicionCohete) {
                gameOver = true
                
                // Efectos de colisión
                AudioManager.shared.playSystemSound(.failure)
                
                // Guardar puntuación en historial
                historialPuntuaciones.append(puntuacion)
                historialPuntuaciones.sort(by: >)
                if historialPuntuaciones.count > 5 {
                    historialPuntuaciones = Array(historialPuntuaciones.prefix(5))
                }
                
                timer?.invalidate()
                break
            }
        }
        
        // Verificar colisiones de disparos con meteoritos
        var disparosAEliminar: Set<UUID> = []
        var meteoritosAEliminar: Set<String> = []
        
        for disparo in disparos {
            for meteorito in meteoritos {
                if abs(disparo.y - meteorito.y) < 15 && disparo.carril == meteorito.carril {
                    disparosAEliminar.insert(disparo.id)
                    meteoritosAEliminar.insert(meteorito.id)
                    puntuacion += puntosPorDisparo
                    
                    // Efectos de destrucción
                    AudioManager.shared.playSystemSound(.success)
                    break
                }
            }
        }
        
        // Eliminar meteoritos y disparos que colisionaron
        meteoritos.removeAll { meteoritosAEliminar.contains($0.id) }
        disparos.removeAll { disparosAEliminar.contains($0.id) }
        
        // Eliminar meteoritos que salen de la pantalla
        let meteoritosEvadidosAntes = meteoritosEvadidos
        meteoritos.removeAll { meteorito in
            if meteorito.y > altoPantalla + 20 {
                meteoritosEvadidos += 1
                puntuacion += puntosPorEvasion
                return true
            }
            return false
        }
        
        // Verificar si se alcanzó el número de meteoritos para disparo
        if meteoritosEvadidos >= meteoritosParaDisparo && !puedeDisparar {
            puedeDisparar = true
            mostrarAvisoDisparo = true
            opacidadAviso = 1.0
            
            // Efectos de power-up
            AudioManager.shared.playSystemSound(.success)
            
            // Animar la aparición y desaparición del aviso
            withAnimation(Animation.easeOut(duration: 2.0)) {
                opacidadAviso = 0
            }
            
            // Ocultar el aviso después de la animación
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                mostrarAvisoDisparo = false
            }
        }
        
        // Eliminar disparos que salen de la pantalla
        disparos.removeAll { $0.y < -20 }
        
        // Verificar victoria
        if puntuacion >= puntuacionMaxima {
            gameOver = true
            
            // Efectos de victoria
            AudioManager.shared.playSystemSound(.success)
            
            // Guardar puntuación en historial
            historialPuntuaciones.append(puntuacion)
            historialPuntuaciones.sort(by: >)
            if historialPuntuaciones.count > 5 {
                historialPuntuaciones = Array(historialPuntuaciones.prefix(5))
            }
            
            timer?.invalidate()
        }
    }
    
    // Función mejorada para mover el cohete
    private func moverCohete(direccion: Direccion) {
        let nuevaPosicion: CGFloat
        switch direccion {
        case .izquierda:
            nuevaPosicion = max(0, posicionCohete - 1)
        case .derecha:
            nuevaPosicion = min(2, posicionCohete + 1)
        }
        
        // Solo mover si la posición ha cambiado
        if nuevaPosicion != posicionCohete {
            withAnimation(.easeInOut(duration: 0.1)) {
                posicionCohete = nuevaPosicion
            }
            producirHaptico()
        }
    }
    
    // Enum para las direcciones
    private enum Direccion {
        case izquierda
        case derecha
    }
    
    func producirHaptico() {
        AudioManager.shared.playSystemSound(.click)
    }
    
    func disparar() {
        let tiempoActual = Date()
        if puedeDisparar && tiempoActual.timeIntervalSince(ultimoDisparo) >= tiempoEntreDisparos {
            let nuevoDisparo = Disparo(carril: Int(posicionCohete), y: altoPantalla - 35)
            disparos.append(nuevoDisparo)
            ultimoDisparo = tiempoActual
            
            // Efectos de disparo
            AudioManager.shared.playSystemSound(.directionUp)
        }
    }
}

// Cohete con estilo pixel art
struct CohetePixelArt: View {
    var animacionLlama: Bool
    var puedeDisparar: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Punta del cohete
            Rectangle()
                .fill(Color.red)
                .frame(width: 6, height: 6)
            
            // Cuerpo principal
            Rectangle()
                .fill(Color.white)
                .frame(width: 12, height: 18)
            
            // Alas
            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 4, height: 6)
                
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 12, height: 6)
                
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 4, height: 6)
            }
            
            // Llamas con animación
            Rectangle()
                .fill(Color.orange)
                .frame(width: 8, height: animacionLlama ? 8 : 5)
            
            Rectangle()
                .fill(Color.yellow)
                .frame(width: 6, height: animacionLlama ? 4 : 3)
            
            // Indicador de disparo
            if puedeDisparar {
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 4, height: 4)
                    .padding(.top, 2)
            }
        }
    }
}

// Meteorito con estilo pixel art
struct MeteoritoPixelArt: View {
    var body: some View {
        ZStack {
            // Capa exterior
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Color.clear
                    Rectangle().fill(Color.gray)
                    Rectangle().fill(Color.gray)
                    Color.clear
                }
                .frame(height: 6)
                
                HStack(spacing: 0) {
                    Rectangle().fill(Color.gray)
                    Rectangle().fill(Color.darkGray)
                    Rectangle().fill(Color.darkGray)
                    Rectangle().fill(Color.gray)
                }
                .frame(height: 6)
                
                HStack(spacing: 0) {
                    Rectangle().fill(Color.gray)
                    Rectangle().fill(Color.darkGray)
                    Rectangle().fill(Color.darkGray)
                    Rectangle().fill(Color.gray)
                }
                .frame(height: 6)
                
                HStack(spacing: 0) {
                    Color.clear
                    Rectangle().fill(Color.gray)
                    Rectangle().fill(Color.gray)
                    Color.clear
                }
                .frame(height: 6)
            }
        }
    }
}

// Extensión para color gris oscuro
extension Color {
    static let darkGray = Color(red: 0.3, green: 0.3, blue: 0.3)
}

struct Meteorito: Identifiable {
    let id: String
    let carril: Int // 0, 1, 2 (izquierda, centro, derecha)
    var y: CGFloat
}

struct Disparo: Identifiable {
    let id = UUID()
    let carril: Int
    var y: CGFloat
}

#Preview {
    ContentView()
}
