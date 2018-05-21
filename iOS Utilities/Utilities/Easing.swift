//
//  Easing.swift
//  iOS Utilities
//
//  Created by Stuart Foulston on 21/05/2018.
//  Copyright © 2018 Stuart Foulston. All rights reserved.
//

import Foundation

public struct Easing {
	
	// MARK: Types
	
	/// Standard easing functions available through the `Easing` class. These
	/// are typical easing curves, rather than complex system responses.
	public enum Function {
		case linear
		case quadratic
		case cubic
		case quartic
		case quintic
		case sinusoidal
		case circular
		case exponential
	}
	
	public enum Direction {
		case positive
		case negative
	}
	
	public enum Curve {
		case inOut
		case `in`
		case out
	}
	
	// MARK: Easing Functions
	
	public static func ease(_ t: Double, function: Function = .linear, curve: Curve = .inOut, direction: Direction = .positive, domain: ClosedRange<Double> = 0...1, range: ClosedRange<Double> = 0...1) -> Double {
		if t < domain.lowerBound {
			switch direction {
			case .positive: return range.lowerBound
			case .negative: return range.upperBound
			}
		} else if t > domain.upperBound {
			switch direction {
			case .positive: return range.upperBound
			case .negative: return range.lowerBound
			}
		}
		let relativeT = t - domain.lowerBound									// From 0.0 to the full length
		let normalisedT = relativeT / (domain.upperBound - domain.lowerBound)	// From 0.0 to 1.0
		var output = block(for: function, curve: curve)(normalisedT)
		if direction == .negative {
			output = 1 - output
		}
		output *= range.upperBound - range.lowerBound	// Re-establish correct length
		output += range.lowerBound						// Shift output to the correct start
		return output
	}
	
	public static func ease(_ t: Double, undampedNaturalFrequency omega: Double, dampingRatio zeta: Double, direction: Direction = .positive) -> Double {
		var output = secondOrderSystemResponse(undampedNaturalFrequency: omega)(zeta)(t)
		if direction == .negative {
			output = 1 - output
		}
		return output
	}
	
	public static func blockForEasingFunction(_ function: Function, curve: Curve = .inOut, direction: Direction = .positive) -> (Double) -> Double {
		let easingFunction = block(for: function, curve: curve)
		switch direction {
		case .positive:
			return easingFunction
		case .negative:
			return { t in 1 - easingFunction(t) }
		}
	}
	
	public static func blockForSecondOrderSystemResponse(_ direction: Direction = .positive, undampedNaturalFrequency omega: Double, dampingRatio zeta: Double) -> (Double) -> Double {
		if omega <= 0 {
			NSException(
				name: NSExceptionName.invalidArgumentException,
				reason: "Undamped natural frequency must be a positive value.",
				userInfo: nil
				).raise()
		}
		if zeta < 0 || zeta >= 1 {
			NSException(
				name: NSExceptionName.invalidArgumentException,
				reason: "Damping ratio must be between 0.0 and 1.0",
				userInfo: nil
				).raise()
		}
		return secondOrderSystemResponse(undampedNaturalFrequency: omega)(zeta)
	}
}

// MARK: Approximated Bezier Timing Functions

public extension Easing {
	
	public static func exponentialEaseOutTimingFunction() -> CAMediaTimingFunction {
		return CAMediaTimingFunction(controlPoints: 0.15625, 0.99805, 0.3, 0.99219)
	}
}

// MARK: Fundamental Easing Functions

private extension Easing {
	
	static func block(for function: Function, curve: Curve) -> (Double) -> Double {
		switch function {
		case .linear:
			return linear
		case .quadratic:
			switch curve {
			case .inOut:	return quadraticEaseInOut
			case .in:		return quadraticEaseIn
			case .out:		return quadraticEaseOut
			}
		case .cubic:
			switch curve {
			case .inOut:	return cubicEaseInOut
			case .in:		return cubicEaseIn
			case .out:		return cubicEaseOut
			}
		case .quartic:
			switch curve {
			case .inOut:	return quarticEaseInOut
			case .in:		return quarticEaseIn
			case .out:		return quarticEaseOut
			}
		case .quintic:
			switch curve {
			case .inOut:	return quinticEaseInOut
			case .in:		return quinticEaseIn
			case .out:		return quinticEaseOut
			}
		case .sinusoidal:
			switch curve {
			case .inOut:	return sinusoidalEaseInOut
			case .in:		return sinusoidalEaseIn
			case .out:		return sinusoidalEaseOut
			}
		case .circular:
			switch curve {
			case .inOut:	return circularEaseInOut
			case .in:		return circularEaseIn
			case .out:		return circularEaseOut
			}
		case .exponential:
			switch curve {
			case .inOut:	return exponentialEaseInOut
			case .in:		return exponentialEaseIn
			case .out:		return exponentialEaseOut
			}
		}
	}
	
	/// Modeled after the line: `y = x`.
	static func linear(_ t: Double) -> Double {
		return t
	}
	
	/// Modeled after the parabola: `y = x^2`.
	static func quadraticEaseIn(_ t: Double) -> Double {
		return t * t
	}
	
	/// Modeled after the parabola: `y = -x^2 + 2x`.
	static func quadraticEaseOut(_ t: Double) -> Double {
		return -(t * (t - 2))
	}
	
	/// Modeled after the piecewise quadratic:
	///
	///     y = (1/2)((2x)^2)              // [0, 0.5]
	///     y = -(1/2)((2x-1)*(2x-3) - 1)  // [0.5, 1]
	static func quadraticEaseInOut(_ t: Double) -> Double {
		if t < 0.5 {
			return 2 * t * t
		} else {
			return (-2 * t * t) + (4 * t) - 1
		}
	}
	
	/// Modeled after the cubic: `y = x^3`.
	static func cubicEaseIn(_ t: Double) -> Double {
		return t * t * t
	}
	
	/// Modeled after the cubic `y = (x - 1)^3 + 1`.
	static func cubicEaseOut(_ t: Double) -> Double {
		let f = t - 1
		return f * f * f + 1
	}
	
	/// Modeled after the piecewise cubic:
	///
	///		y = (1/2)((2x)^3)        // [0, 0.5)
	///		y = (1/2)((2x-2)^3 + 2)	 // [0.5, 1]
	static func cubicEaseInOut(_ t: Double) -> Double {
		if t < 0.5 {
			return 4 * t * t * t
		} else {
			let f = (2 * t) - 2
			return 0.5 * f * f * f + 1
		}
	}
	
	/// Modeled after the quartic: `x^4`.
	static func quarticEaseIn(_ t: Double) -> Double {
		return t * t * t * t
	}
	
	/// Modeled after the quartic: `y = 1 - (x - 1)^4`.
	static func quarticEaseOut(_ t: Double) -> Double {
		let f = t - 1
		return f * f * f * (1 - t) + 1
	}
	
	/// Modeled after the piecewise quartic:
	///
	///		y = (1/2)((2x)^4)        // [0, 0.5)
	///		y = -(1/2)((2x-2)^4 - 2) // [0.5, 1]
	static func quarticEaseInOut(_ t: Double) -> Double {
		if t < 0.5 {
			return 8 * t * t * t * t
		} else {
			let f = t - 1
			return -8 * f * f * f * f + 1
		}
	}
	
	/// Modeled after the quintic: `y = x^5`.
	static func quinticEaseIn(_ t: Double) -> Double {
		return t * t * t * t * t
	}
	
	/// Modeled after the quintic: `y = (x - 1)^5 + 1`.
	static func quinticEaseOut(_ t: Double) -> Double {
		let f = t - 1
		return f * f * f * f * f + 1
	}
	
	/// Modeled after the piecewise quintic
	///
	///		y = (1/2)((2x)^5)       // [0, 0.5)
	///		y = (1/2)((2x-2)^5 + 2) // [0.5, 1]
	static func quinticEaseInOut(_ t: Double) -> Double {
		if t < 0.5 {
			return 16 * t * t * t * t * t
		} else {
			let f = (2 * t) - 2
			return  0.5 * f * f * f * f * f + 1
		}
	}
	
	/// Modeled after quarter-cycle of sine wave.
	static func sinusoidalEaseIn(_ t: Double) -> Double {
		return sin((t - 1) * .pi / 2) + 1
	}
	
	/// Modeled after quarter-cycle of sine wave (different phase).
	static func sinusoidalEaseOut(_ t: Double) -> Double {
		return sin(t * .pi / 2)
	}
	
	/// Modeled after half sine wave.
	static func sinusoidalEaseInOut(_ t: Double) -> Double {
		return 0.5 * (1 - cos(t * .pi))
	}
	
	/// Modeled after shifted quadrant IV of unit circle.
	static func circularEaseIn(_ t: Double) -> Double {
		return 1 - sqrt(1 - (t * t))
	}
	
	/// Modeled after shifted quadrant II of unit circle.
	static func circularEaseOut(_ t: Double) -> Double {
		return sqrt((2 - t) * t)
	}
	
	/// Modeled after the piecewise circular function:
	///
	///		y = (1/2)(1 - sqrt(1 - 4x^2))           // [0, 0.5)
	///		y = (1/2)(sqrt(-(2x - 3)*(2x - 1)) + 1) // [0.5, 1]
	static func circularEaseInOut(_ t: Double) -> Double {
		if t < 0.5 {
			return 0.5 * (1 - sqrt(1 - 4 * (t * t)))
		} else {
			return 0.5 * (sqrt(-((2 * t) - 3) * ((2 * t) - 1)) + 1)
		}
	}
	
	/// Modeled after the exponential function: `y = 2^(10(x - 1))`.
	static func exponentialEaseIn(_ t: Double) -> Double {
		return t == 0 ? t : pow(2, 10 * (t - 1))
	}
	
	/// Modeled after the exponential function: `y = -2^(-10x) + 1`.
	static func exponentialEaseOut(_ t: Double) -> Double {
		return t == 1 ? t : 1 - pow(2, -10 * t)
	}
	
	/// Modeled after the piecewise exponential:
	///
	///		y = (1/2)2^(10(2x - 1))         // [0,0.5)
	///		y = -(1/2)*2^(-10(2x - 1))) + 1 // [0.5,1]
	static func exponentialEaseInOut(_ t: Double) -> Double {
		if t == 0 || t == 1 {
			return t
		}
		if t < 0.5 {
			return 0.5 * pow(2, (20 * t) - 10)
		} else {
			return -0.5 * pow(2, (-20 * t) + 10) + 1
		}
	}
	
	static func secondOrderSystemResponse(undampedNaturalFrequency omega: Double) -> (_ dampingRatio: Double) -> (_ t: Double) -> Double {
		return { zeta in
			return { t in
				let beta = sqrt(1 - (zeta * zeta))
				let phi = atan(beta / zeta);
				return 1 + -1 / beta * exp(-zeta * omega * t) * sin(beta * omega * t + phi)
			}
		}
	}
}
