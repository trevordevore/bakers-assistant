script "sanjose19.drawings.drawing"

/*******************************************************************************
 *
 * DRAWING FORMAT - VERSION 0
 *
 * A drawing is a simple bytecode format for representing graphics expressed
 * using SVG. It consists of a header, followed by a sequence of bytecodes
 * encoded in bytes, and a sequence of scalars encoded as floats.
 *
 * The format is such that it requires no extra data structures at runtime
 * except whilst rendering.
 *
 * The header has the following format:
 *   uint8_t[4] ident = 'L', 'C', 'D', 0
 *   float width
 *   float height
 *   uint32_t scalar_count
 *   float[scalar_count] scalars
 *   uint32_t opcode_count
 *   uint8_t[opcode_count] opcodes
 *
 * The ident field is used to identify a drawing, allowing simple 'sniffing' of
 * the first four bytes to help determine the format.
 *
 * The last byte of the ident field is the version of the format - currently 0.
 * This will be incremented each time the format changes in a backwards
 * incompatible way.
 *
 * The width and height fields are the 'natural' size of the drawing. This is
 * used (in the engine) to present as the formattedWidth/Height and to provide
 * the 'natural' size used for generating pixels (in which case the ceiling is
 * used).
 *
 * There are several kinds of scalar which may be present:
 *
 *   - coordinate : any scalar value
 *
 *   - unit : a value between 0 and 1
 *
 *   - length : a value greater or equal to 0
 *
 *   - positive : a value greater or equal to 1
 *
 *   - size : a value greater or equal to -1; values less than 0 represent
 *     a percentage (divided by -100), values greater or equal to 0 represent
 *     absolute values.
 *
 */

constant kMCGDrawingIdent = "LCD"
constant kMCGDrawingVersion = 0

constant kMCGDrawingOpcodeEnd = 0
constant kMCGDrawingOpcodeTransform = 1
constant kMCGDrawingOpcodeFillPaint = 2
constant kMCGDrawingOpcodeFillOpacity = 3
constant kMCGDrawingOpcodeFillRule = 4
constant kMCGDrawingOpcodeStrokePaint = 5
constant kMCGDrawingOpcodeStrokeOpacity = 6
constant kMCGDrawingOpcodeStrokeWidth = 7
constant kMCGDrawingOpcodeStrokeLineJoin = 8
constant kMCGDrawingOpcodeStrokeLineCap = 9
constant kMCGDrawingOpcodeStrokeDashArray = 10
constant kMCGDrawingOpcodeStrokeDashOffset = 11
constant kMCGDrawingOpcodeStrokeMiterLimit = 12
constant kMCGDrawingOpcodeRectangle = 13
constant kMCGDrawingOpcodeRoundedRectangle = 14
constant kMCGDrawingOpcodeCircle = 15
constant kMCGDrawingOpcodeEllipse = 16
constant kMCGDrawingOpcodeLine = 17
constant kMCGDrawingOpcodePolyline = 18
constant kMCGDrawingOpcodePolygon = 19
constant kMCGDrawingOpcodePath = 20

constant kMCGDrawingTransformOpcodeIdentity = 0
constant kMCGDrawingTransformOpcodeAffine = 1

constant kMCGDrawingPaintOpcodeNone = 0
constant kMCGDrawingPaintOpcodeSolidColor = 1
constant kMCGDrawingPaintOpcodeLinearGradient = 2
constant kMCGDrawingPaintOpcodeRadialGradient = 3
constant kMCGDrawingPaintOpcodeConicalGradient = 4
constant kMCGDrawingPaintOpcodeCurrentColor = 5

constant kMCGDrawingSpreadMethodOpcodePad = 0
constant kMCGDrawingSpreadMethodOpcodeReflect = 1
constant kMCGDrawingSpreadMethodOpcodeRepeat = 2

constant kMCGDrawingFillRuleOpcodeNonZero = 0
constant kMCGDrawingFillRuleOpcodeEvenOdd = 1

constant kMCGDrawingStrokeLineJoinOpcodeBevel = 0
constant kMCGDrawingStrokeLineJoinOpcodeRound = 1
constant kMCGDrawingStrokeLineJoinOpcodeMiter = 2

constant kMCGDrawingStrokeLineCapOpcodeButt = 0
constant kMCGDrawingStrokeLineCapOpcodeRound = 1
constant kMCGDrawingStrokeLineCapOpcodeSquare = 2

constant kMCGDrawingPathOpcodeEnd = 0
constant kMCGDrawingPathOpcodeMoveTo = 1
constant kMCGDrawingPathOpcodeLineTo = 2
constant kMCGDrawingPathOpcodeHorizontalTo = 3
constant kMCGDrawingPathOpcodeVerticalTo = 4
constant kMCGDrawingPathOpcodeCubicTo = 5
constant kMCGDrawingPathOpcodeSmoothCubicTo = 6
constant kMCGDrawingPathOpcodeQuadraticTo= 7
constant kMCGDrawingPathOpcodeSmoothQuadraticTo = 8
constant kMCGDrawingPathOpcodeArcTo = 9
constant kMCGDrawingPathOpcodeReflexArcTo = 10
constant kMCGDrawingPathOpcodeReverseArcTo = 11
constant kMCGDrawingPathOpcodeReverseReflexArcTo = 12
constant kMCGDrawingPathOpcodeCloseSubpath = 13

/******************************************************************************/

/* LIFECYCLE */

command drawingStart @xContext, pWidth, pHeight
  put empty into xContext

  put binaryEncode("A3Cff", \
           kMCGDrawingIdent, \
           kMCGDrawingVersion, \
           pWidth, pHeight) into xContext["header"]
  put empty into xContext["scalars"]
  put empty into xContext["opcodes"]
end drawingStart

command drawingFinish @xContext, @rDrawing
  put xContext["header"] into rDrawing
  put binaryEncode("I", \
           the number of bytes in xContext["scalars"] div 4) after rDrawing
  put xContext["scalars"] after rDrawing
  put binaryEncode("I", \
           the number of bytes in xContext["opcodes"]) after rDrawing
  put xContext["opcodes"] after rDrawing
  put empty into xContext
end drawingFinish

/* TRANSFORMS */

command drawingSetTransform @xContext, pTransform
  put numToByte(kMCGDrawingOpcodeTransform) after xContext["opcode"]
  _drawingEmitTransform xContext, pTransform
end drawingSetTransform

command drawingSetIdentityTransform @xContext
  put numToByte(kMCGDrawingOpcodeTransform) & \
    numToByte(kMCGDrawingTransformOpcodeIdentity) after xContext["opcodes"]
end drawingSetIdentityTransform

command drawingSetAffineTransform @xContext, pA, pB, pC, pD, pTx, pTy
  put numToByte(kMCGDrawingOpcodeTransform) & \
    numToByte(kMCGDrawingTransformOpcodeAffine) after xContext["opcodes"]
  put binaryEncode("ffffff", pA, pB, pC, pD, pTx, pTy) after xContext["scalars"]
end drawingSetAffineTransform

/* FILL ATTRIBUTES */

command drawingSetFillPaint @xContext, pPaint
  put numToByte(kMCGDrawingOpcodeFillPaint) after xContext["opcodes"]
  _drawingEmitPaint xContext, pPaint
end drawingSetFillPaint

command drawingSetNoFillPaint @xContext
  put numToByte(kMCGDrawingOpcodeFillPaint) & \
    numToByte(kMCGDrawingPaintOpcodeNone) after xContext["opcodes"]
end drawingSetNoFillPaint

command drawingSetSolidColorFillPaint @xContext, pRed, pGreen, pBlue, pAlpha
  put numToByte(kMCGDrawingOpcodeFillPaint) & \
    numToByte(kMCGDrawingPaintOpcodeSolidColor) after xContext["opcodes"]
  put binaryEncode("ffff", pRed, pGreen, pBlue, pAlpha) after xContext["scalars"]
end drawingSetSolidColorFillPaint

command drawingSetLinearGradientFillPaint @xContext, pSpread, pTransform, pRamp
  put numToByte(kMCGDrawingOpcodeFillPaint) after xContext["opcodes"]
  _drawingEmitLinearGradient xContext, pSpread, pTransform, pRamp
end drawingSetLinearGradientFillPaint

command drawingSetRadialGradientFillPaint @xContext, pSpread, pTransform, pRamp
  put numToByte(kMCGDrawingOpcodeFillPaint) after xContext["opcodes"]
  _drawingEmitRadialGradient xContext, pSpread, pTransform, pRamp
end drawingSetRadialGradientFillPaint

command drawingSetConicalGradientFillPaint @xContext, pSpread, pTransform, pRamp, pFx, pFy, pFr
  put numToByte(kMCGDrawingOpcodeFillPaint) after xContext["opcodes"]
  _drawingEmitConicalGradient xContext, pSpread, pTransform, pRamp, pFx, pFy, pFr
end drawingSetConicalGradientFillPaint

command drawingSetCurrentColorFillPaint @xContext, pRed, pGreen, pBlue, pAlpha
  put numToByte(kMCGDrawingOpcodeFillPaint) & \
    numToByte(kMCGDrawingPaintOpcodeCurrentColor) after xContext["opcodes"]
end drawingSetCurrentColorFillPaint

command drawingSetFillOpacity @xContext, pOpacity
  put numToByte(kMCGDrawingOpcodeFillOpacity) after xContext["opcodes"]
  put binaryEncode("f", pOpacity) after xContext["scalars"]
end drawingSetFillOpacity

command drawingSetFillRule @xContext, pRule
  put numToByte(kMCGDrawingOpcodeFillRule) & \
    _drawingEncodeFillRule(pRule) after xContext["opcodes"]
end drawingSetFillRule

/* STROKE ATTRIBUTES */

command drawingSetStrokePaint @xContext, pPaint
  put numToByte(kMCGDrawingOpcodeStrokePaint) after xContext["opcodes"]
  _drawingEmitPaint xContext, pPaint
end drawingSetStrokePaint

command drawingSetNoStrokePaint @xContext
  put numToByte(kMCGDrawingOpcodeStrokePaint) & \
    numToByte(kMCGDrawingPaintOpcodeNone) after xContext["opcodes"]
end drawingSetNoStrokePaint

command drawingSetSolidColorStrokePaint @xContext, pRed, pGreen, pBlue, pAlpha
  put numToByte(kMCGDrawingOpcodeStrokePaint) & \
    numToByte(kMCGDrawingPaintOpcodeSolidColor) after xContext["opcodes"]
  put binaryEncode("ffff", pRed, pGreen, pBlue, pAlpha) after xContext["scalars"]
end drawingSetSolidColorStrokePaint

command drawingSetLinearGradientStrokePaint @xContext, pSpread, pTransform, pRamp
  put numToByte(kMCGDrawingOpcodeStrokePaint) after xContext["opcodes"]
  _drawingEmitLinearGradient xContext, pSpread, pTransform, pRamp
end drawingSetLinearGradientStrokePaint

command drawingSetRadialGradientStrokePaint @xContext, pSpread, pTransform, pRamp
  put numToByte(kMCGDrawingOpcodeStrokePaint) after xContext["opcodes"]
  _drawingEmitRadialGradient xContext, pSpread, pTransform, pRamp
end drawingSetRadialGradientStrokePaint

command drawingSetConicalGradientStrokePaint @xContext, pSpread, pTransform, pRamp, pFx, pFy, pFr
  put numToByte(kMCGDrawingOpcodeStrokePaint) after xContext["opcodes"]
  _drawingEmitConicalGradient xContext, pSpread, pTransform, pRamp, pFx, pFy, pFr
end drawingSetConicalGradientStrokePaint

command drawingSetCurrentColorStrokePaint @xContext, pRed, pGreen, pBlue, pAlpha
  put numToByte(kMCGDrawingOpcodeStrokePaint) & \
    numToByte(kMCGDrawingPaintOpcodeCurrentColor) after xContext["opcodes"]
end drawingSetCurrentColorStrokePaint

command drawingSetStrokeOpacity @xContext, pOpacity
  put numToByte(kMCGDrawingOpcodeStrokeOpacity) after xContext["opcodes"]
  put binaryEncode("f", pOpacity) after xContext["scalars"]
end drawingSetStrokeOpacity

command drawingSetStrokeWidth @xContext, pWidth
  put numToByte(kMCGDrawingOpcodeStrokeWidth) after xContext["opcodes"]
  put binaryEncode("f", pWidth) after xContext["scalars"]
end drawingSetStrokeWidth

command drawingSetStrokeLineJoin @xContext, pJoin
  put numToByte(kMCGDrawingOpcodeStrokeLineJoin) & \
    _drawingEncodeLineJoin(pJoin) after xContext["opcodes"]
end drawingSetStrokeLineJoin

command drawingSetStrokeLineCap @xContext, pCap
  put numToByte(kMCGDrawingOpcodeStrokeLineCap) & \
    _drawingEncodeLineCap(pCap) after xContext["opcodes"]
end drawingSetStrokeLineCap

command drawingSetStrokeDashArray @xContext, pDashArray
  put numToByte(kMCGDrawingOpcodeStrokeDashArray) & \
    numToByte(the number of elements in pDashArray) after xContext["opcodes"]
  repeat for each element tDash in pDashArray
    put binaryEncode("f", tDash) after xContext["scalars"]
  end repeat
end drawingSetStrokeDashArray

command drawingSetStrokeDashOffset @xContext, pDashOffset
  put numToByte(kMCGDrawingOpcodeStrokeDashOffset) after xContext["opcodes"]
  put binaryEncode("f", pDashOffset) after xContext["scalars"]
end drawingSetStrokeDashOffset

command drawingSetStrokeMiterLimit @xContext, pMiterLimit
  put numToByte(kMCGDrawingOpcodeStrokeMiterLimit) after xContext["opcodes"]
  put binaryEncode("f", pMiterLimit) after xContext["scalars"]
end drawingSetStrokeMiterLimit

/* SHAPES */

command drawingTraceRectangle @xContext, pX, pY, pWidth, pHeight
  put numToByte(kMCGDrawingOpcodeRectangle) after xContext["opcodes"]
  put binaryEncode("ffff", pX, pY, pWidth, pHeight) after xContext["scalars"]
end drawingTraceRectangle

command drawingTraceRoundedRectangle @xContext, pX, pY, pWidth, pHeight, pRx, pRy
  put numToByte(kMCGDrawingOpcodeRoundedRectangle) after xContext["opcodes"]
  put binaryEncode("ffffff", pX, pY, pWidth, pHeight, pRx, pRy) after xContext["scalars"]
end drawingTraceRoundedRectangle

command drawingTraceCircle @xContext, pCx, pCy, pRadius
  put numToByte(kMCGDrawingOpcodeCircle) after xContext["opcodes"]
  put binaryEncode("fff", pCx, pCy, pRadius) after xContext["scalars"]
end drawingTraceCircle

command drawingTraceEllipse @xContext, pCx, pCy, pRx, pRy
  put numToByte(kMCGDrawingOpcodeEllipse) after xContext["opcodes"]
  put binaryEncode("ffff", pCx, pCy, pRx, pRy) after xContext["scalars"]
end drawingTraceEllipse

command drawingTraceLine @xContext, pX1, pY1, pX2, pY2
  put numToByte(kMCGDrawingOpcodeLine) after xContext["opcodes"]
  put binaryEncode("ffff", pX1, pY1, pX2, pY2) after xContext["scalars"]
end drawingTraceLine

command drawingTracePolyline @xContext, pPoints
  local tPoints
  repeat for each element tPoint in pPoints
    put binaryEncode("ff", tPoint["x"], tPoint["y"]) after tPoints
  end repeat
  put numToByte(kMCGDrawingOpcodePolyline) & \
    numToByte(the number of elements in pPoints * 2) after xContext["opcodes"]
  put tPoints after xContext["scalars"]
end drawingTracePolyline

command drawingTracePolygon @xContext, pPoints
  local tPoints
  repeat for each element tPoint in pPoints
    put binaryEncode("ff", tPoint["x"], tPoint["y"]) after tPoints
  end repeat
  put numToByte(kMCGDrawingOpcodePolygon) & \
    numToByte(the number of elements in pPoints * 2) after xContext["opcodes"]
  put tPoints after xContext["scalars"]
end drawingTracePolygon

/* PATHS */

command drawingTraceBeginPath @xContext
  put numToByte(kMCGDrawingOpcodePath) after xContext["opcodes"]
end drawingTraceBeginPath

command drawingTraceMoveTo @xContext, pX, pY
  put numToByte(kMCGDrawingPathOpcodeMoveTo) after xContext["opcodes"]
  put binaryEncode("ff", pX, pY) after xContext["scalars"]
end drawingTraceMoveTo

command drawingTraceLineTo @xContext, pX, pY
  put numToByte(kMCGDrawingPathOpcodeLineTo) after xContext["opcodes"]
  put binaryEncode("ff", pX, pY) after xContext["scalars"]
end drawingTraceLineTo

command drawingTraceHorizontalTo @xContext, pX
  put numToByte(kMCGDrawingPathOpcodeHorizontalTo) after xContext["opcodes"]
  put binaryEncode("f", pX) after xContext["scalars"]
end drawingTraceHorizontalTo

command drawingTraceVerticalTo @xContext, pY
  put numToByte(kMCGDrawingPathOpcodeVerticalTo) after xContext["opcodes"]
  put binaryEncode("f", pY) after xContext["scalars"]
end drawingTraceVerticalTo

command drawingTraceCubicTo @xContext, pAx, pAy, pBx, pBy, pX, pY
  put numToByte(kMCGDrawingPathOpcodeCubicTo) after xContext["opcodes"]
  put binaryEncode("ffffff", pAx, pAy, pBx, pBy, pX, pY) after xContext["scalars"]
end drawingTraceCubicTo

command drawingTraceSmoothCubicTo @xContext, pTx, pTy, pX, pY
  put numToByte(kMCGDrawingPathOpcodeSmoothCubicTo) after xContext["opcodes"]
  put binaryEncode("ffff", pTx, pTy, pX, pY) after xContext["scalars"]
end drawingTraceSmoothCubicTo

command drawingTraceQuadraticTo @xContext, pCx, pCy, pX, pY
  put numToByte(kMCGDrawingPathOpcodeQuadraticTo) after xContext["opcodes"]
  put binaryEncode("ffff", pCx, pCy, pX, pY) after xContext["scalars"]
end drawingTraceQuadraticTo

command drawingTraceSmoothQuadraticTo @xContext, pX, pY
  put numToByte(kMCGDrawingPathOpcodeSmoothQuadraticTo) after xContext["opcodes"]
  put binaryEncode("ff", pX, pY) after xContext["scalars"]
end drawingTraceSmoothQuadraticTo

command drawingTraceArcTo @xContext, pCx, pCy, pRotation, pX, pY
  put numToByte(kMCGDrawingPathOpcodeArcTo) after xContext["opcodes"]
  put binaryEncode("fffff", pCx, pCy, pRotation, pX, pY) after xContext["scalars"]
end drawingTraceArcTo

command drawingTraceReflexArcTo @xContext, pCx, pCy, pRotation, pX, pY
  put numToByte(kMCGDrawingPathOpcodeReflexArcTo) after xContext["opcodes"]
  put binaryEncode("fffff", pCx, pCy, pRotation, pX, pY) after xContext["scalars"]
end drawingTraceReflexArcTo

command drawingTraceReverseArcTo @xContext, pCx, pCy, pRotation, pX, pY
  put numToByte(kMCGDrawingPathOpcodeReverseArcTo) after xContext["opcodes"]
  put binaryEncode("fffff", pCx, pCy, pRotation, pX, pY) after xContext["scalars"]
end drawingTraceReverseArcTo

command drawingTraceReverseReflexArcTo @xContext, pCx, pCy, pRotation, pX, pY
  put numToByte(kMCGDrawingPathOpcodeReverseReflexArcTo) after xContext["opcodes"]
  put binaryEncode("fffff", pCx, pCy, pRotation, pX, pY) after xContext["scalars"]
end drawingTraceReverseReflexArcTo

command drawingTraceCloseSubpath @xContext
  put numToByte(kMCGDrawingPathOpcodeCloseSubpath) after xContext["opcodes"]
end drawingTraceCloseSubpath

command drawingTraceEndPath @xContext
  put numToByte(kMCGDrawingPathOpcodeEnd) after xContext["opcodes"]
end drawingTraceEndPath

/* FILL ATTRIBUTES (INTERNAL) */

private function _drawingEncodeFillRule pRule
  switch pRule
  case "nonZero"
    return numToByte(kMCGDrawingFillRuleOpcodeNonZero)
  case "evenOdd"
    return numToByte(kMCGDrawingFillRuleOpcodeEvenOdd)
  default
    break
  end switch
  throw "not a fill rule"
end _drawingEncodeFillRule

/* STROKE ATTRIBUTES (INTERNAL) */

private function _drawingEncodeLineJoin pJoin
  switch pJoin
  case "bevel"
    return numToByte(kMCGDrawingStrokeLineJoinOpcodeBevel)
  case "round"
    return numToByte(kMCGDrawingStrokeLineJoinOpcodeRound)
  case "miter"
    return numToByte(kMCGDrawingStrokeLineJoinOpcodeMiter)
  default
    break
  end switch
  throw "not a line join"
end _drawingEncodeLineJoin

private function _drawingEncodeLineCap pCap
  switch pCap
  case "butt"
    return numToByte(kMCGDrawingStrokeLineCapOpcodeButt)
  case "round"
    return numToByte(kMCGDrawingStrokeLineCapOpcodeRound)
  case "square"
    return numToByte(kMCGDrawingStrokeLineCapOpcodeSquare)
  default
    break
  end switch
  throw "not a line join"
end _drawingEncodeLineCap

/* PAINTS (INTERNAL) */

private command _drawingEmitPaint @xContext, pPaint
  if pPaint is an array then
    switch pPaint["kind"]
    case "none"
      put numToByte(kMCGDrawingPaintOpcodeNone) after xContext["opcodes"]
      break
    case "solidColor"
      put numToByte(kMCGDrawingPaintOpcodeSolidColor) after xContext["opcodes"]
      put binaryEncode("ffff", \
               pPaint["red"], \
               pPaint["green"], \
               pPaint["blue"], \
               pPaint["alpha"]) after xContext["scalars"]
      break
    case "linearGradient"
      _drawingEmitLinearGradient xContext, \
                    pPaint["spread"], \
                    pPaint["transform"], \
                    pPaint["ramp"]
      break
    case "radialGradient"
      _drawingEmitRadialGradient xContext, \
                    pPaint["spread"], \
                    pPaint["transform"], \
                    pPaint["ramp"]
      break
    case "conicalGradient"
      _drawingEmitLinearGradient xContext, \
                    pPaint["spread"], \
                    pPaint["transform"], \
                    pPaint["ramp"], \
                    pPaint["fx"], \
                    pPaint["fy"], \
                    pPaint["fr"]
      break
    case "currentColor"
      put numToByte(kMCGDrawingPaintOpcodeCurrentColor) after xContext["opcodes"]
      break

    default
      throw "not a paint"
      break
    end switch
    exit _drawingEmitPaint
  end if

  switch pPaint
  case empty
  case "none"
    put numToByte(kMCGDrawingPaintOpcodeNone) after xContext["opcodes"]
    break
  case "currentColor"
    put numToByte(kMCGDrawingPaintOpcodeCurrentColor) after xContext["opcodes"]
    break
  default
    throw "not a paint"
    break
  end switch
end _drawingEmitPaint

/* TRANSFORMS (INTERNAL) */

private command _drawingEmitTransform @xContext, pTransform
  if pTransform is an array then
    switch pTransform["kind"]
    case "identity"
      put numToByte(kMCGDrawingTransformOpcodeIdentity) after xContext["opcodes"]
      break
    case "affine"
      put numToByte(kMCGDrawingTransformOpcodeAffine) after xContext["opcodes"]
      put binaryEncode("ffffff", \
               pTransform["a"], pTransform["b"], \
               pTransform["c"], pTransform["d"], \
               pTransform["tx"], pTransform["ty"]) after xContext["scalars"]
      break
    default
      throw "not a transform"
      break
    end switch
    exit _drawingEmitTransform
  end if

  switch pTransform
  case empty
  case "identity"
    put numToByte(kMCGDrawingTransformOpcodeIdentity) after xContext["opcodes"]
    break
  default
    throw "not a transform"
    break
  end switch
end _drawingEmitTransform

/* GRADIENTS (INTERNAL) */

private command _drawingEmitLinearGradient @xContext, pSpread, pTransform, pRamp
  _drawingEmitGradient xContext, \
              kMCGDrawingPaintOpcodeLinearGradient, \
              pSpread, \
              pTransform, \
              pRamp
end _drawingEmitLinearGradient

private command _drawingEmitRadialGradient @xContext, pSpread, pTransform, pRamp
  _drawingEmitGradient xContext, \
              kMCGDrawingPaintOpcodeRadialGradient, \
              pSpread, \
              pTransform, \
              pRamp
end _drawingEmitRadialGradient

private command _drawingEmitConicalGradient @xContext, pSpread, pTransform, pRamp, pFx, pFy, pFr
  _drawingEmitGradient xContext, \
              kMCGDrawingPaintOpcodeConicalGradient, \
              pSpread, \
              pTransform, \
              pRamp
  put binaryEncode("fff", pFx, pFy, pFr) after xContext["scalars"]
end _drawingEmitConicalGradient

private command _drawingEmitGradient @xContext, pOpcode, pSpread, pTransform, pRamp
  put numToByte(pOpcode) after xContext["opcodes"]
  _drawingEmitSpreadMethod xContext, pSpread
  _drawingEmitTransform xContext, pTransform
  _drawingEmitRamp xContext, pRamp
end _drawingEmitGradient

private command _drawingEmitSpreadMethod @xContext, pSpreadMethod
  local tOpcode
  switch pSpreadMethod
  case "pad"
    put kMCGDrawingSpreadMethodOpcodePad into tOpcode
    break
  case "reflect"
    put kMCGDrawingSpreadMethodOpcodeReflect into tOpcode
    break
  case "repeat"
    put kMCGDrawingSpreadMethodOpcodeRepeat into tOpcode
    break
  default
    throw "not a spread method"
    break
  end switch
  put numToByte(tOpcode) after xContext["opcodes"]
end _drawingEmitSpreadMethod

private command _drawingEmitRamp @xContext, pRamp
  local tColors, tOffsets
  repeat for each element tStop in pRamp
    put binaryEncode("ffff", \
              tStop["red"], tStop["green"], tStop["blue"], \
              tStop["alpha"]) after tColors
    put binaryEncode("f", tStop["offset"]) after tOffsets
  end repeat

  put numToByte(the number of elements in pRamp) after xContext["opcodes"]
  put tColors after xContext["scalars"]
  put tOffsets after xContext["scalars"]
end _drawingEmitRamp

