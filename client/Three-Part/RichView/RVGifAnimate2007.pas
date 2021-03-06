{*******************************************************}
{                                                       }
{       RichView                                        }
{       TRVGifImageAnimator: displaying animation for   }
{       TGifImage from Delphi 2007  .                   }
{                                                       }
{       Copyright (c) Sergey Tkachenko                  }
{       svt@trichview.com                               }
{       http://www.trichview.com                        }
{                                                       }
{*******************************************************}

{$I RV_Defs.inc}

unit RVGifAnimate2007;

interface

{$IFNDEF RVDONOTUSEANIMATION}

uses Windows, Classes, Graphics, DLines,
     CRVFData, RVAnimate, RVItem, GifImg;

type
  { ---------------------------------------------------------------------------
    TRVGifImageAnimator: displaying animations for gif images
    (using TGifImage from Delphi 2007)
    Variables:
      bmp: the current frame of animation
      bmpsrc: background under the image (if it is not a plain color, otherwise
        it's nil)
      FX, FY - the stored values of image position. Used to check if the image
        is moved.
      FParaNo - the stored value of paragraph image. Used to check if the
        paragraph is changed (may be it's background was changed?)
      FLastDrawnFrameIndex - index of the frame drawn in bmp.
  }
  TRVGifImageAnimator = class (TRVAnimator)
    private
      bmp, bmpsrc: TBitmap;
      FBackColor: TColor;
      FX,FY, FParaNo, FLastDrawnFrameIndex: Integer;
      procedure CalcInterval;
    protected
      function GetFrameCount: Integer; override;
      procedure ResetBackground; override;
    public
      destructor Destroy; override;
      procedure Reset; override;
      procedure ChangeFrame; override;
      procedure Draw(X, Y: Integer; Canvas: TCanvas; Animation: Boolean); override;
      function GetExportImageSize: TSize; override;
      procedure DrawForExport(Canvas: TCanvas); override;      
  end;

{$ENDIF}

implementation

{$IFNDEF RVDONOTUSEANIMATION}
{================================= TRVGifImageAnimator ========================}
{ Destructor }
destructor TRVGifImageAnimator.Destroy;
begin
  bmp.Free;
  bmpsrc.Free;
  inherited;
end;
{------------------------------------------------------------------------------}
{ Determines how long to display the current frame. }
procedure TRVGifImageAnimator.CalcInterval;
var gif: TGifImage;
begin
  gif := TGifImage(TRVGraphicItemInfo(item).Image);
  Interval := 10; //GIFDefaultDelay;
  if gif.Images[FrameIndex].GraphicControlExtension=nil then
    exit;
  if gif.Images[FrameIndex].GraphicControlExtension.Delay > 0 then begin
    Interval := gif.Images[FrameIndex].GraphicControlExtension.Delay;
    if (Interval < GIFMinimumDelay) then
      Interval := GIFMinimumDelay;
    if (Interval > GIFMaximumDelay) then
      Interval := GIFMaximumDelay;
  end;
  Interval := Interval*10;
end;
{------------------------------------------------------------------------------}
{ Change frame to the next one. Updates Interval. }
procedure TRVGifImageAnimator.ChangeFrame;
begin
  CalcNextFrameIndex;
  CalcInterval;
end;
{------------------------------------------------------------------------------}
{ Clears the stored background info }
procedure TRVGifImageAnimator.ResetBackground;
begin
  bmpsrc.Free;
  bmpsrc := nil;
  bmp.Free;
  bmp := nil;
end;
{------------------------------------------------------------------------------}
type
  TGifFrameHack = class (TGifFrame)
  end;

{ Draws the current frame }
procedure TRVGifImageAnimator.Draw(X, Y: Integer; Canvas: TCanvas; Animation: Boolean);
var gif: TGifImage;
    i: Integer;
    UseSrcBitmap: Boolean;
    r: TRect;
    function ScaleRect(const DestRect: TRect; FrameIndex: Integer): TRect;
    var
      HeightMul, HeightDiv  : integer;
      WidthMul, WidthDiv  : integer;
    begin
      with gif.Images[FrameIndex] do begin
        HeightDiv := gif.Height;
        HeightMul := DestRect.Bottom-DestRect.Top;
        WidthDiv := gif.Width;
        WidthMul := DestRect.Right-DestRect.Left;

        Result.Left := DestRect.Left + muldiv(Left, WidthMul, WidthDiv);
        Result.Top := DestRect.Top + muldiv(Top, HeightMul, HeightDiv);
        Result.Right := DestRect.Left + muldiv(Left+Width, WidthMul, WidthDiv);
        Result.Bottom := DestRect.Top + muldiv(Top+Height, HeightMul, HeightDiv);
      end;
    end;

    procedure MakeBitmap(FrameIndex: Integer);
    var r: TRect;
    begin
      if (FrameIndex>0) and (gif.Images[FrameIndex-1].GraphicControlExtension<>nil) then
        case gif.Images[FrameIndex-1].GraphicControlExtension.Disposal of
          dmBackground:
            begin
              r := ScaleRect(Rect(0, 0, item.GetImageWidth(nil), item.GetImageHeight(nil)), FrameIndex-1);
              if bmpsrc<>nil then
                bmp.Canvas.CopyRect(r, bmpsrc.Canvas, r)
              else begin
                bmp.Canvas.Brush.Color := FBackColor;
                bmp.Canvas.FillRect(r);
              end;
            end;
        end
      else begin
        if bmpsrc<>nil then
          bmp.Assign(bmpsrc)
        else begin
          bmp.Canvas.Brush.Color := FBackColor;
          bmp.Canvas.FillRect(Rect(0,0,bmp.Width,bmp.Height));
        end;
      end;

      gif.Images[FrameIndex].StretchDraw(bmp.Canvas,
        ScaleRect(Rect(0, 0, item.GetImageWidth(nil), item.GetImageHeight(nil)), FrameIndex),
        gif.Images[FrameIndex].Transparent, False);
      gif.Images[FrameIndex].HasBitmap := False;
      //gif.Images[FrameIndex].FreeMask;
      gif.Images[FrameIndex].Palette := 0;
      gif.Palette := 0
    end;

begin
  gif := TGifImage(TRVGraphicItemInfo(item).Image);
  if (bmp=nil) or
    (item.ParaNo<>FParaNo) or
    (X<>FX) or
    (Y<>FY) or
    (bmp.Width<>item.GetImageWidth(nil)) or
    (bmp.Height<>item.GetImageHeight(nil)) then begin
    bmp.Free;
    bmp := TBitmap.Create;
    bmp.Width := item.GetImageWidth(nil);
    bmp.Height := item.GetImageHeight(nil);
    FParaNo := item.ParaNo;
    FX := X;
    FY := Y;
    if gif.Transparent then begin
      r := Rect(0,0,0,0);
      RVData.GetItemBackground(RVData.DrawItems[item.DrawItemNo].ItemNo, r, True,
        FBackColor, bmpsrc, UseSrcBitmap);
      if not UseSrcBitmap then begin
        bmp.Canvas.Brush.Color := RVData.GetColor;
        bmp.Canvas.FillRect(Rect(0,0,bmp.Width,bmp.Height));
      end;
      end
    else begin
      FBackColor := clWhite;
      UseSrcBitmap := False;
    end;
    if not UseSrcBitmap then begin
      bmpsrc.Free;
      bmpsrc := nil;
    end;
    for i := 0 to FrameIndex-1 do
      MakeBitmap(i);
    end
  else if (FrameIndex=FLastDrawnFrameIndex) then begin
    Canvas.Draw(X,Y,bmp);
    exit;
    end
  else if (FrameIndex>0) and (FLastDrawnFrameIndex<>FrameIndex-1) then begin
    if FLastDrawnFrameIndex<FrameIndex then begin
      for i := FLastDrawnFrameIndex+1 to FrameIndex-1 do
        MakeBitmap(i);
      end
    else
      for i := 0 to FrameIndex-1 do
        MakeBitmap(i);
  end;
  MakeBitmap(FrameIndex);
  FLastDrawnFrameIndex := FrameIndex;
  Canvas.Draw(X,Y,bmp);
end;
{------------------------------------------------------------------------------}
{ Draws the first frame for RTF export }
procedure TRVGifImageAnimator.DrawForExport(Canvas: TCanvas);
var gif: TGIFImage;
    r: TRect;
begin
  gif := TGifImage(TRVGraphicItemInfo(item).Image);
  Canvas.Brush.Color := clWhite;
  Canvas.Brush.Style := bsSolid;
  Canvas.FillRect(Rect(0, 0, gif.Width, gif.Height));
  with gif.Images[0] do
    r := Bounds(Left, Top, Width, Height);
  gif.Images[0].Draw(Canvas, r, gif.Images[0].Transparent, False);
  gif.Images[0].HasBitmap := False;
end;
{------------------------------------------------------------------------------}
{ Image size for RTF saving }
function TRVGifImageAnimator.GetExportImageSize: TSize;
begin
  Result.cy := TGifImage(TRVGraphicItemInfo(item).Image).Height;
  Result.cx := TGifImage(TRVGraphicItemInfo(item).Image).Width;
end;
{------------------------------------------------------------------------------}
{ Returns a number of frames in gif }
function GetGifFrameCount(gif: TGifImage): Integer;
begin
  Result := gif.Images.Count;
  while (Result>1) and gif.Images[Result-1].Empty do
    dec(Result);
end;
{------------------------------------------------------------------------------}
{ Returns a number of frames }
function TRVGifImageAnimator.GetFrameCount: Integer;
begin
  Result := TGifImage(TRVGraphicItemInfo(item).Image).Images.Count;
  while (Result>1) and
    TGifImage(TRVGraphicItemInfo(item).Image).Images[Result-1].Empty do
    dec(Result);
end;
{------------------------------------------------------------------------------}
{ Rewinds to the first frame. Updates Interval. }
procedure TRVGifImageAnimator.Reset;
begin
  bmp.Free;
  bmp := nil;
  bmpsrc.Free;
  bmpsrc := nil;
  FrameIndex := 0;
  FLastDrawnFrameIndex := -1;
  CalcInterval;
end;
{==============================================================================}
var DefMakeAnimator: TRVMakeAnimatorProc;
{ This procedure creates an animator (anim) for the item, if it's necessary.
  This procedure can create only TRVGifImageAnimator.
  If it cannot be applied, it calls the stored value of RV_MakeAnimator. }
procedure RV_MakeAnimatorGif(item: TCustomRVItemInfo; RVData: TCustomRVFormattedData;
  var anim: TRVAnimator);
begin
  if (item is TRVGraphicItemInfo) and
     (TRVGraphicItemInfo(item).Image is TGifImage) and
     (GetGifFrameCount(TGifImage(TRVGraphicItemInfo(item).Image))>1) then begin
    if (anim<>nil) and not (anim is TRVGifImageAnimator) then begin
      anim.Free;
      anim := nil;
    end;
    if anim=nil then begin
      anim := TRVGifImageAnimator.Create(RVData, Item);
      RVData.InsertAnimator(TObject(anim));
      end
    else if anim<>nil then begin
      anim.Update(RVData, Item);
      anim.Reset;
    end;
    exit;
  end;
  DefMakeAnimator(item, RVData, anim)
end;

initialization
  DefMakeAnimator := RV_MakeAnimator;
  RV_MakeAnimator := RV_MakeAnimatorGif;

{$ENDIF}

end.