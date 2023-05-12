//
//  ContentView.swift
//  Oven
//
//  Created by 금가경 on 2023/05/06.
//

import SwiftUI

extension Comparable {
    func clamp<T: Comparable>(lower: T, _ upper: T) -> T {
        return min(max(self as! T, lower), upper)
    }
}

extension CGSize {
    static var inactiveThumbSize:CGSize {
        return CGSize(width: 50, height: 50)
    }

    static var activeThumbSize:CGSize {
        return CGSize(width: 85, height: 50)
    }

    static var trackSize:CGSize {
        return CGSize(width: 280, height: 50)
    }
}

extension HomeView {
    func onSwipeSuccess(_ action: @escaping () -> Void ) -> Self {
        var this = self
        this.actionSuccess = action
        return this
    }
}


struct HomeView: View {

    // we want to animate the thumb size when user starts dragging (swipe)
    @State private var thumbSize:CGSize = CGSize.inactiveThumbSize

    // we need to keep track of the dragging value. Initially its zero
    @State private var dragOffset:CGSize = .zero

    // Lets also keep track of when enough was swiped
    @State private var isEnough = false

    // Actions
    private var actionSuccess: (() -> Void )?


    // The track does not change size
    let trackSize = CGSize.trackSize
//    let view = HomeView()

    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                ZStack {
                    Color(red: 0.15, green: 0.15, blue: 0.15)
                        .ignoresSafeArea()
                    //                            Image("line")
                    //                                .resizable()
                    //                                .scaledToFit()
                    //                                .edgesIgnoringSafeArea(.all)
                    //                                .frame(alignment: .center)
                    //
                    // Swipe Track
                    
                    NavigationLink(destination:OnboardingView()){
                        Image(systemName: "questionmark.app.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(Color(red: 255, green: 188, blue: 0))
                            .frame(width: thumbSize.width * 10, height: thumbSize.height)
                    }
//                    .frame(width: view.size.width, height: view.size.height)
                    .offset(x:130, y:-330)
                    
                    ZStack{
                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: trackSize.width, height: trackSize.height)
                            .foregroundColor(Color.black).blendMode(.overlay).opacity(0.5)
                    }
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: thumbSize.width, height: thumbSize.height)
                            .foregroundColor(Color(red: 255, green: 188, blue: 0))
                        //                                    .shadow(color: .black, radius: 10)
                        Image(systemName: "arrow.right")
                            .foregroundColor(Color.black)
                    }
                    
                    //                            // Help text
                    //                            Text("slide to start")
                    ////                                .font(.title)
                    //                                .foregroundColor(.gray)
                    //                                .offset(x: 30, y: 0)
                    //                                .opacity(Double(1 - ( (self.dragOffset.width*2)/self.trackSize.width)))
                    //
                    // Thumb
                    
                    .offset(x: getDragOffsetX(), y: 0)
                    .animation(Animation.spring(response: 0.2, dampingFraction: 0.8))
                    .gesture(
                        DragGesture()
                            .onChanged({ value in self.handleDragChanged(value) })
                            .onEnded({ _ in self.handleDragEnded() })
                    )
                    
                }
                
            }
        }
    }
    
    
    // MARK: - Haptic feedback
    private func indicateCanLiftFinger() -> Void {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    private func indicateSwipeWasSuccessful() -> Void {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }


    // MARK: - Helpers
    private func getDragOffsetX() -> CGFloat {
        // should not be able to drag outside of the track area

        let clampedDragOffsetX = dragOffset.width.clamp(lower: 0, trackSize.width - thumbSize.width)

        return -( trackSize.width/2 - thumbSize.width/2 - (clampedDragOffsetX))
    }

    // MARK: - Gesture Handlers
    private func handleDragChanged(_ value:DragGesture.Value) -> Void {
        self.dragOffset = value.translation

        let dragWidth = value.translation.width
        let targetDragWidth = self.trackSize.width - (self.thumbSize.width*2)
//        let wasInitiated = dragWidth > 2
        let didReachTarget = dragWidth > targetDragWidth

        self.thumbSize = CGSize.inactiveThumbSize

        if didReachTarget {
            // only trigger once!
            if !self.isEnough {
                self.indicateCanLiftFinger()
            }
            self.isEnough = true
        }
        else {
            self.isEnough = false
        }
    }

    private func handleDragEnded() -> Void {
        // If enough was dragged, complete swipe
        if self.isEnough {
            self.dragOffset = CGSize(width: self.trackSize.width - self.thumbSize.width, height: 0)

            // the outside world should be able to know
            if nil != self.actionSuccess {
                self.indicateSwipeWasSuccessful()

                // wait and give enough time for animation to finish
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    self.actionSuccess!()
                }
            }

        }
        else {
            self.dragOffset = .zero
            self.thumbSize = CGSize.inactiveThumbSize
        }



    }

}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}



