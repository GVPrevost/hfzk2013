object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Form2'
  ClientHeight = 457
  ClientWidth = 712
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 305
    Top = 150
    Height = 307
    ExplicitLeft = 360
    ExplicitTop = 200
    ExplicitHeight = 100
  end
  object Memo1: TMemo
    Left = 0
    Top = 150
    Width = 305
    Height = 307
    Align = alLeft
    Lines.Strings = (
      'Memo1')
    TabOrder = 0
    ExplicitTop = 0
    ExplicitHeight = 457
  end
  object wb: TWebBrowser
    Left = 0
    Top = 0
    Width = 712
    Height = 150
    Align = alTop
    TabOrder = 1
    ExplicitLeft = 8
    ExplicitTop = 56
    ControlData = {
      4C00000096490000810F00000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object Button1: TButton
    Left = 344
    Top = 248
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 2
    OnClick = Button1Click
  end
end