{
  This file is part of ParsIMoS, a software for parsing input files for IMoS.

  Author
            Jean R. N. Haler - jean.haler@ulg.ac.be (University of Liège - Mass Spectrometry Laboratory)

  Developed with the beta testers
            Christopher Kune - c.kune@ulg.ac.be (University of Liège - Mass Spectrometry Laboratory)
            Dr. Johann Far - johann.far@ulg.ac.be (University of Liège - Mass Spectrometry Laboratory)

  Supervisor
            Prof. Edwin De Pauw - e.depauw@ulg.ac.be (University of Liège - Mass Spectrometry Laboratory)

  parsimos@outlook.com

—————————————————————————————————————————————
  Copyright (c) 2016-2017 University of Liège

  Licensed under the Apache License, Version 2.0 (the "License »); you may not use
  this file except in compliance with the License. You may obtain a copy of the License at
  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software distributed
  under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
  CONDITIONS OF ANY KIND, either express or implied. See the License for the
  specific language governing permissions and limitations under the License.
—————————————————————————————————————————————
}

unit parsimos_unit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, ExtCtrls, fpspreadsheet, fpstypes, xlsxooxml, fpsUtils, StrUtils, fileinfo,
  winpeimagereader, elfreader, machoreader;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnConvert: TButton;
    btnInfo: TButton;
    btnloadlastparam: TButton;
    BtnBrowseInputFile: TButton;
    BtnCopyFromAtomIdentif: TButton;
    BtnBrowseSelectionFile: TButton;
    BtnAddmorefiles: TButton;
    ChkboxNoCharge: TCheckBox;
    Chkboxmobcal: TCheckBox;
    ChkboxAtomIdentifsamesect: TCheckBox;
    ChkboxAtomIdentifothersect: TCheckBox;
    ChkboxChargesamesect: TCheckBox;
    ChkboxChargeothersect: TCheckBox;
    ChkboxInputFile: TCheckBox;
    ChkboxAPT: TCheckBox;
    ChkboxGauss: TCheckBox;
    ChkboxMull: TCheckBox;
    ChkboxNBO: TCheckBox;
    Chkboxatomidentletter: TCheckBox;
    Chkboxatomidentinteg: TCheckBox;
    ChkboxAll: TCheckBox;
    ChkboxSelect: TCheckBox;
    CBFormat: TComboBox;
    GBgeneral: TGroupBox;
    GBparams: TGroupBox;
    Label12: TLabel;
    lblOutputFormat: TLabel;
    Label7: TLabel;
    lbledtChargeotherline: TLabeledEdit;
    lblcompany: TLabel;
    lbledtAtomIdentifotherline: TLabeledEdit;
    lbledtfirstline: TLabeledEdit;
    lblversion: TLabel;
    Logo_ULg: TImage;
    Logo_MSLab: TImage;
    Logo_FNRS: TImage;
    lblLoadedFiles: TLabel;
    Label11: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    lbledtemptylin: TLabeledEdit;
    lbledtatomchargcol: TLabeledEdit;
    lbledtxcoordcol: TLabeledEdit;
    lbledtatomidentcol: TLabeledEdit;
    lbledtnumcoltot: TLabeledEdit;
    lbledtnumsets: TLabeledEdit;
    lbledtnumatoms: TLabeledEdit;
    lbledtcharge: TLabeledEdit;
    lbledtmass: TLabeledEdit;
    lbledtycoordcol: TLabeledEdit;
    lbledtzcoordcol: TLabeledEdit;
    lblpercentage: TLabel;
    MemoDisplayInputName: TMemo;
    ProgressBar1: TProgressBar;
    procedure BtnAddmorefilesClick(Sender: TObject);
    procedure BtnAddmorefilesMouseEnter(Sender: TObject);
    procedure BtnBrowseInputFileClick(Sender: TObject);
    procedure BtnBrowseInputFileMouseEnter(Sender: TObject);
    procedure btnConvertClick(Sender: TObject);
    procedure BtnCopyFromAtomIdentifClick(Sender: TObject);
    procedure btnInfoClick(Sender: TObject);
    procedure btnloadlastparamClick(Sender: TObject);
    procedure BtnBrowseSelectionFileClick(Sender: TObject);
    procedure BtnBrowseSelectionFileMouseEnter(Sender: TObject);
    procedure CBFormatChange(Sender: TObject);
    procedure ChkboxAllChange(Sender: TObject);
    procedure ChkboxAPTChange(Sender: TObject);
    procedure ChkboxAtomIdentifothersectChange(Sender: TObject);
    procedure ChkboxAtomIdentifsamesectChange(Sender: TObject);
    procedure ChkboxatomidentintegChange(Sender: TObject);
    procedure ChkboxatomidentletterChange(Sender: TObject);
    procedure ChkboxChargeothersectChange(Sender: TObject);
    procedure ChkboxChargesamesectChange(Sender: TObject);
    procedure ChkboxGaussChange(Sender: TObject);
    procedure ChkboxInputFileChange(Sender: TObject);
    procedure ChkboxmobcalChange(Sender: TObject);
    procedure ChkboxMullChange(Sender: TObject);
    procedure ChkboxNBOChange(Sender: TObject);
    procedure ChkboxNoChargeChange(Sender: TObject);
    procedure ChkboxSelectChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure lbledtAtomIdentifotherlineMouseEnter(Sender: TObject);
    procedure lbledtChargeotherlineMouseEnter(Sender: TObject);
    procedure lbledtxcoordcolExit(Sender: TObject);
    procedure MemoDisplayInputNameMouseEnter(Sender: TObject);

  private
    { private declarations }
    DelimitersList, inputPandF:TStringList;                  //Local variables for this form
    selectPandF:string;
    AtomNameRadius:array of array of string;
  public
    { public declarations }
    FileContents:TStringList;                                //Global variables for this form

  end;

var
  Form1: TForm1;

implementation

uses
  newsearchstring;

{$R *.lfm}

{ TForm1 }

function FindDelimiters(const Source:String; const DelimitersList:TStringLIst; var FoundDelimitersList:TStringList):integer;        //Find the delimiters present in a given section; will only be used on the first line of each section
var                                                                                                                                 //whole sections are encoded the same way -> one check is sufficient
  sourcestring, car{, controlstring}:string;
  counter{, i}:integer;
  Found:boolean;
begin
  sourcestring:=source;
  counter:=1;
  Found:=False;

  while (counter <= Length(sourcestring)) do
  begin
    car:=Copy(sourcestring,counter,1);                                //first, second,.... character in line is copied and analyzed

    Found:=False;
    if (DelimitersList.IndexOf(car) >= 0) then                        //Search in the complete delimiterlist; if the delimiter is found, the function gives the element number (>=0); otherwise it will yield '-1' ('-1' means it isn't a delimiter)
      Found:=True;

    if (Found = True) then
    begin                                                             //Save the delimiters which were found (search based on the complete delimiterslist)
      if (FoundDelimitersList.Count = 0) then                         //first found delimiter saved to the list
        FoundDelimitersList.Add(car);
      if (FoundDelimitersList.Count <> 0) then                        //once the list contains elements: search if we had already found the delimiter or if it is a new one from the complete delimiterlist
      begin
        if (FoundDelimitersList.IndexOf(car) = -1) then               //check if it is a new delimiter which has not yet been encountered in the string ('-1') and save it . if the delimiter was already saved, the function gives the element number (>=0)
          FoundDelimitersList.Add(car);
      end;
    end;

    counter:=counter+1;                                               //if no delimiter is found, continue search with next element in the string
  end;

  {controlstring:='';
  for i:=0 to (FoundDelimitersList.Count-1) do
    controlstring:=controlstring+'Delim'+FoundDelimitersList[i]+'Delim';
  ShowMessage('Number of found Delimiters: '+IntToStr(FoundDelimitersList.Count));
  ShowMessage('Found these delimiters: '+controlstring);}

  result:=FoundDelimitersList.Count;
end;

function SplitLineAsList(const Source:String; const FoundDelimitersList:TStringList; var LineasList:TStringList):integer;      //Parser Function
var
  sourcestring, res, car{, controlstring}:string;
  counter{, i}:integer;
begin
  sourcestring:=Trim(Source);
  counter:=1;
  res:='';

  while (counter <= Length(sourcestring)) do
  begin
    car:=Copy(sourcestring,counter,1);                              //first character in line is copied and analyzed

    if (FoundDelimitersList.IndexOf(car) = -1) then                 //search if car is one of the previously identified delimiters; -1 :no, >= :yes
      res:=res+car;

    if (FoundDelimitersList.IndexOf(car) >= 0) then                 //once a delimiter is found the string is saved as an element in the StringList if the string isn't empty
    begin
      if (res <> '') then
      begin
        LineasList.Add(res);
        res:=''
      end;
    end;

    counter:=counter+1;
  end;

  LineasList.Add(res);                                              //last string in the line before char(13) or equivalent ('enter')
  res:='';

  {controlstring:='';
  for i:=0 to (LineasList.Count-1) do
    controlstring:=controlstring+char(13)+LineasList[i];
  ShowMessage('Parsed line: '+controlstring);}

  result:=LineasList.Count;                                           //number of elements we parsed between the delimiters
end;

procedure TForm1.btnConvertClick(Sender: TObject);       //Conversion/Parse Button
var
  Param_backup: text;
  Para: AnsiString;
  Workbk: TsWorkbook;
  Worksh: TsWorksheet;
  Xcoord, Ycoord, Zcoord, Charge,AtomIdentif: array of string;
  inputstream:TFileStream;
  SelectContents,FoundDelimitersList, LineasList: TStringList;
  sheetnumtot, sheetnum, firstline, filecount, selectcount, i, k, l, lengthmax, NumberOfAtoms, chargetot, emptylines: integer;
  colx, coly, colz, colatomid, colatomcharg: integer;
  line, dir, newfilename:string;
  perc, mass, summedmass:real;
  hit, found, Stopping, trymulliken, nomulliken:boolean;

begin

  {Securities if parameter is missing -> program won't crash}
  if (ChkboxInputFile.Checked=False) then
  begin
    ShowMessage('Please select an input file.');
    BtnBrowseInputFileClick(Sender);
  end;

  if ChkboxGauss.Checked=true then
  begin
    if lbledtnumatoms.Text='' then
    begin
      lbledtnumatoms.Color:=clRed;
      lbledtnumatoms.Text:=inputbox('Missing parameter detected','Please insert the number of atoms','');
      lbledtnumatoms.Color:=clDefault;
    end;
  end;

  if ChkboxGauss.Checked=false then
  begin
    if lbledtnumatoms.Text='' then
    begin
      lbledtnumatoms.Color:=clRed;
      lbledtnumatoms.Text:=inputbox('Missing parameter detected','Please insert the number of atoms','');
      lbledtnumatoms.Color:=clDefault;
    end;
    if lbledtfirstline.Text='' then
    begin
      lbledtfirstline.Color:=clRed;
      lbledtfirstline.Text:=inputbox('Missing parameter detected','Please insert the line number of the first coordinate set','');
      lbledtfirstline.Color:=clDefault;
    end;
    if lbledtnumsets.Text='' then
    begin
      lbledtnumsets.Color:=clRed;
      lbledtnumsets.Text:=inputbox('Missing parameter detected','Please insert the number of structures/sets of coordinates','');
      lbledtnumsets.Color:=clDefault;
    end;
    if lbledtnumcoltot.Text='' then
    begin
      lbledtnumcoltot.Color:=clRed;
      lbledtnumcoltot.Text:=inputbox('Missing parameter detected','Please insert the number of columns','');
      lbledtnumcoltot.Color:=clDefault;
    end;
    if lbledtxcoordcol.Text='' then
    begin
      lbledtxcoordcol.Color:=clRed;
      lbledtxcoordcol.Text:=inputbox('Missing parameter detected','Please insert the X coordinates column number','');
      lbledtxcoordcol.Color:=clDefault;
    end;
    if lbledtycoordcol.Text='' then
    begin
      lbledtycoordcol.Color:=clRed;
      lbledtycoordcol.Text:=inputbox('Missing parameter detected','Please insert the Y coordinates column number','');
      lbledtycoordcol.Color:=clDefault;
    end;
    if lbledtzcoordcol.Text='' then
    begin
      lbledtzcoordcol.Color:=clRed;
      lbledtzcoordcol.Text:=inputbox('Missing parameter detected','Please insert the Z coordinates column number','');
      lbledtzcoordcol.Color:=clDefault;
    end;
    if lbledtatomidentcol.Text='' then
    begin
      lbledtatomidentcol.Color:=clRed;
      lbledtatomidentcol.Text:=inputbox('Missing parameter detected','Please insert the atom identifiers column number','');
      lbledtatomidentcol.Color:=clDefault;
    end;
    if ChkboxNoCharge.Checked=False then
    begin
      if lbledtatomchargcol.Text='' then
      begin
        lbledtatomchargcol.Color:=clRed;
        lbledtatomchargcol.Text:=inputbox('Missing parameter detected','Please insert the atom charges column number','');
        lbledtatomchargcol.Color:=clDefault;
      end;
    end;
    if lbledtemptylin.Text='' then
    begin
      lbledtemptylin.Color:=clRed;
      lbledtemptylin.Text:=inputbox('Missing parameter detected','Please insert the number of lines between sets of coordinates','');
      lbledtemptylin.Color:=clDefault;
    end;
    if (ChkboxChargeothersect.Checked=True) then
    begin
      if (lbledtChargeotherline.Text='') then
      begin
        lbledtChargeotherline.Color:=clRed;
        lbledtChargeotherline.Text:=inputbox('Missing parameter detected','Please insert the line number from where to start reading the atom charges','');
        lbledtChargeotherline.Color:=clDefault;
      end;
    end;
    if (ChkboxAtomIdentifothersect.Checked=True) then
    begin
      if (lbledtAtomIdentifotherline.Text='') then
      begin
        lbledtAtomIdentifotherline.Color:=clRed;
        lbledtAtomIdentifotherline.Text:=inputbox('Missing parameter detected','Please insert the line number from where to start reading the atom identifiers','');
        lbledtAtomIdentifotherline.Color:=clDefault;
      end;
    end;
  end;

  dir:=ProgramDirectory;                                 //directory of the inputs = directory of the .exe
  SetCurrentDir(dir);

  Para:='Last_parameters.par';                           //Backup of last parameters used for encoding
  AssignFile(Param_backup, Para);
  Rewrite(Param_backup);
  writeln(Param_backup,'List of the parameters used for the last encoding.');
  writeln(Param_backup,DateTimeToStr(Now));
  writeln(Param_backup);                                 //3 lines of comments
  writeln(Param_backup,'File(s) to encode:',chr(9),IntToStr(inputPandF.Count));
  for i:=0 to (inputPandF.Count-1) do
  begin
    writeln(Param_backup,'File:',chr(9),inputPandF[i]);
  end;
  writeln(Param_backup,'Output file format:',chr(9),CBFormat.ItemIndex);
  writeln(Param_backup,'Gaussian input:',chr(9),ChkboxGauss.Checked);
  writeln(Param_backup,'Mulliken charges:',chr(9),ChkboxMull.Checked);
  writeln(Param_backup,'APT charges:',chr(9),ChkboxAPT.Checked);
  writeln(Param_backup,'NBO charges:',chr(9),ChkboxNBO.Checked);
  writeln(Param_backup,'Number of Atoms:',chr(9),lbledtnumatoms.Text);
  if lbledtmass.Text='' then
    writeln(Param_backup,'Total Mass:',chr(9),'0')
    else
    writeln(Param_backup,'Total Mass:',chr(9),lbledtmass.Text);
  if lbledtcharge.Text='' then
    writeln(Param_backup,'Total Charge:',chr(9),'0')
    else
    writeln(Param_backup,'Total Charge:',chr(9),lbledtcharge.Text);
  writeln(Param_backup,'Convert entire input:',chr(9),ChkboxAll.Checked);
  writeln(Param_backup,'Convert selection:',chr(9),ChkboxSelect.Checked);
  writeln(Param_backup,'First line number:',chr(9),lbledtfirstline.Text);
  writeln(Param_backup,'Sets of coordinates:',chr(9),lbledtnumsets.Text);
  writeln(Param_backup,'Number of columns:',chr(9),lbledtnumcoltot.Text);
  writeln(Param_backup,'X Coordinates column:',chr(9),lbledtxcoordcol.Text);
  writeln(Param_backup,'Y Coordinates column:',chr(9),lbledtycoordcol.Text);
  writeln(Param_backup,'Z Coordinates column:',chr(9),lbledtzcoordcol.Text);
  writeln(Param_backup,'Atom identifier column:',chr(9),lbledtatomidentcol.Text);
  writeln(Param_backup,'Atom identifier is a letter:',chr(9),Chkboxatomidentletter.Checked);
  writeln(Param_backup,'Atom identifier is an integer:',chr(9),Chkboxatomidentinteg.Checked);
  writeln(Param_backup,'Atom identifier in same section:',chr(9),ChkboxAtomIdentifsamesect.Checked);
  writeln(Param_backup,'Atom identifier in other section:',chr(9),ChkboxAtomIdentifothersect.Checked);
  writeln(Param_backup,'Atom identifier in other line:',chr(9),lbledtAtomIdentifotherline.Text);
  writeln(Param_backup,'Atom charge column:',chr(9),lbledtatomchargcol.Text);
  writeln(Param_backup,'Atom charge in same section:',chr(9),ChkboxChargesamesect.Checked);
  writeln(Param_backup,'Atom charge in other section:',chr(9),ChkboxChargeothersect.Checked);
  writeln(Param_backup,'Atom charge in other line:',chr(9),lbledtChargeotherline.Text);
  writeln(Param_backup,'Lines between sets of coordinates:',chr(9),lbledtemptylin.Text);
  writeln(Param_backup,'Mobcal input:',chr(9),Chkboxmobcal.Checked);
  writeln(Param_backup,'No charge:',chr(9),ChkboxNoCharge.Checked);
  if (ChkboxSelect.Checked=True) then
    writeln(Param_backup,'File with selection of sets of coordinates:',chr(9),selectPandF)
  else
    writeln(Param_backup,'File with selection of sets of coordinates:',chr(9));
  CloseFile(Param_backup);

  if (ChkboxSelect.Checked=True) then
  begin
    SelectContents:=TStringList.Create;
    inputstream:=TFileStream.Create(selectPandF,fmOpenRead);   //Load input file
    SelectContents.LoadfromStream(inputstream);
    inputstream.Free;
  end;

  FileContents:=TStringList.Create;
  LineasList:=TStringList.Create;
  FoundDelimitersList:=TStringList.Create;

  for filecount:=0 to (inputPandF.Count-1) do              //several inputs -> one after the other
  begin
    inputstream:=TFileStream.Create(inputPandF[filecount],fmOpenRead);//Load input file
    FileContents.LoadfromStream(inputstream);
    inputstream.Free;

    for i:=0 to (FileContents.Count-1) do                  //Substitute false paragraph sign which keeps file as 1 single line
    begin
      if ((FileContents[i]=char(255)) or (FileContents[i]=char(160)) or (FileContents[i]=#160)) then
        FileContents[i]:=char(13);
    end;

    if (Chkboxmobcal.Checked=False) then
      NumberOfAtoms:= StrToInt(lbledtnumatoms.Text)
    else
    begin
      NumberOfAtoms:= StrToInt(FileContents[2]);
      sheetnumtot:=StrToInt(FileContents[1]);
    end;

    emptylines:= StrToInt(lbledtemptylin.Text);

    SetLength(Xcoord,NumberOfAtoms);                       //give suitable sizes to data matrices/vectors
    SetLength(Ycoord,NumberOfAtoms);
    SetLength(Zcoord,NumberOfAtoms);
    SetLength(Charge,NumberOfAtoms);
    SetLength(AtomIdentif,NumberOfAtoms);

    colx:= StrToInt(lbledtxcoordcol.Text);
    coly:= StrToInt(lbledtycoordcol.Text);
    colz:= StrToInt(lbledtzcoordcol.Text);
    colatomid:= StrToInt(lbledtatomidentcol.Text);
    colatomcharg:= StrToInt(lbledtatomchargcol.Text);

    if (Chkboxmobcal.Checked=False) then
    begin
      if (ChkboxAll.Checked=True) then
      begin
        sheetnumtot:= StrToInt(lbledtnumsets.Text);          //number of coordinate sets
      end;
    end;
    if (ChkboxAll.Checked=True) then
    begin
      firstline:= StrToInt(lbledtfirstline.Text)-1;           //line from which we will begin parsing (coordinates,...)
    end;
    if (ChkboxGauss.Checked=True) then
    begin
      sheetnumtot:=StrToInt(lbledtnumsets.Text);           //number of sets of coordinates; encoded by default; firstline to be determined afterwards (different for coordinates, charges etc.)
    end;
    if (ChkboxSelect.Checked=True) then
    begin
      selectcount:=1;                                      //counter of sets of coordinates; maximum:SelectContents.Count-1; -1 b/c 1 line description
      sheetnumtot:= (SelectContents.Count-1);              //number of selected structures = number of line in selection.txt (SelectContents) & + 1line of comments
      firstline:= (((StrToInt(SelectContents[selectcount])-1)*NumberOfAtoms) + ((StrToInt(SelectContents[selectcount])-1)*emptylines) + (StrToInt(lbledtfirstline.Text)-1));   //1st set of selected coordinates + jump empty lines + lines for description (mobcal etc.)
      ShowMessage('First Set: '+SelectContents[selectcount] +sLineBreak+'Firstline: '+IntToStr(firstline));
    end;

    //ShowMessage('Number of atoms: '+IntToStr(NumberOfAtoms)+sLineBreak+'Number of sets of coordinates: '+IntToStr(sheetnumtot));

    ProgressBar1.Hide;                                     //Progress Bar for encoding
    ProgressBar1.Position:=0;
    ProgressBar1.Max:=sheetnumtot;
    lblpercentage.Hide;

    if (ChkboxGauss.Checked=True) then                     //Gaussian input firstline definition for x,y,z coordinates
    begin
      found:=False;                                        //Optimized geometries
      k:=0;
      while ((found=False) and (k<=(FileContents.Count-1))) do
      begin
        if (AnsiContainsText(Trim(FileContents[k]),'optimization completed')=False) then k:=k+1
        else
        begin
          l:=k;
          while ((found=False) and (l<=(FileContents.Count-1))) do
          begin
            if (AnsiContainsText(Trim(FileContents[l]),'standard orientation')=False) then l:=l+1
            else
            begin
              firstline:=l+5;
              found:=True;
            end;
          end;
        end;
      end;
      if (found=False) then                                //Non-optomized geometries -> Single Point Energy SPE calculations
      begin
        k:=0;
        ShowMessage('No optimized geometry found.' +sLineBreak+ '...continuing with input geometry.');
        while ((found=False) and (k<=(FileContents.Count-1))) do
        begin
          if (AnsiContainsText(Trim(FileContents[k]),'input orientation')=False) then k:=k+1
          else
          begin
            firstline:=k+5;
            found:=True;
          end;
        end;
      end;
    end;

    Workbk:=TsWorkbook.Create;                             //Create spreadsheet workbook

    Stopping:=False;

    for sheetnum:=0 to (sheetnumtot-1) do                  //counter begins at 0 -> sheetnumtot-1
    begin                                                  //loop for reading data & writing into Excel
     if (ChkboxSelect.Checked=True) then
        Worksh:=Workbk.AddWorksheet('struct'+SelectContents[selectcount])   //Create the needed worksheets + give names according to number of the selected structure
     else
        Worksh:=Workbk.AddWorksheet('struct'+IntToStr(sheetnum+1));          //Create the needed worksheets + give names according to number of structure; counter begins at 0

      summedmass:=0;

      ProgressBar1.Show;
      lblpercentage.Show;
      ProgressBar1.Position:=ProgressBar1.Position+1;
      perc:=Round(((sheetnum+1)/sheetnumtot)*100);
      if (inputPandF.Count=1) then
        lblpercentage.Caption:=(FloatToStr(perc)+'%')
      else
        lblpercentage.Caption:=(IntToStr(filecount+1)+'/'+IntToStr(inputPandF.Count)+' '+FloatToStr(perc)+'%');
      Application.ProcessMessages;                                           //Refresh the interface

      FoundDelimitersList.Clear;

      for i:=0 to (NumberOfAtoms-1) do
      begin
        if (ChkboxAll.Checked=True) then
          lengthmax:=sheetnumtot*NumberOfAtoms + (StrToInt(lbledtfirstline.Text)-1) + (sheetnumtot-1)*emptylines;  //sheetnumtot is the total number of sets of coordinates
        if (ChkboxSelect.Checked=True) then
          lengthmax:=firstline + NumberOfAtoms-1;
        if (ChkboxGauss.Checked=True) then
          lengthmax:=firstline + NumberOfAtoms-1;

        if (((i + firstline) <= lengthmax) and ((i+firstline) <= (firstline+NumberOfAtoms-1))) then  //firstline will be increased from set to set
        begin
          line:=FileContents[i + firstline];                                 //i+firstline is the number of the line to be parsed
          LineasList.Clear;
          if (FoundDelimitersList.Count = 0) then                            //Will only take place for the first line of the section -> we select the delimiters actually found from all encoded delimiters
          begin                                                              //a given section will be encoded the same way -> only do it once
            FindDelimiters(line, DelimitersList, FoundDelimitersList);
          end;

          SplitLineAsList(line, FoundDelimitersList, LineasList);            //Parsing function

          if ((ChkboxGauss.Checked=True) and (i=0)) then                     //depending on Gaussian version: 5 or 6 columns total where coordinates have to be read -> adjust colx, coly,colz; only do it once i=0
          begin                                                              //read last 3 columns -> x,y,z
            colx:=LineasList.Count-2;
            coly:=LineasList.Count-1;
            colz:=LineasList.Count;
          end;

          XCoord[i]:=LineasList[colx-1];                                     //LineasList begins at 0
          YCoord[i]:=LineasList[coly-1];
          ZCoord[i]:=LineasList[colz-1];

          if (ChkboxGauss.Checked=False) then                                //other inputs than Gaussian where the atomidentifiers and charges are written in the same lines as the coordinates
          begin
            if (ChkboxAtomIdentifsamesect.Checked = True) then
              AtomIdentif[i]:=LineasList[colatomid-1];
            if (ChkboxNoCharge.Checked=False) then
            begin
              if (ChkboxChargesamesect.Checked = True) then
                Charge[i]:=LineasList[colatomcharg-1];
            end
            else
              Charge[i]:='';
          end;
          //ShowMessage(XCoord[i]+sLineBreak+YCoord[i]+sLineBreak+ZCoord[i]+sLineBreak+AtomIdentif[i]+sLineBreak+Charge[i]);

          if ((sheetnum=0) and (LineasList.Count > (StrToInt(lbledtnumcoltot.Text)))) then       //Message Box if problem encountered
          begin
            case QuestionDlg ('Attention: Too many columns detected',
                   'Too many columns detected.'+sLineBreak+'At least one delimiter was not read correctly.',
                   mtCustom,[mrYes,'Ok, continue', mrNo, 'Please abort the conversion and Save', 'IsDefault'],'') of
                   mrNo: Stopping:=True;
            end;
            if (Stopping=True) then
            begin
              newfilename:=ChangeFileExt(ExtractFileName(inputPandF[filecount]),'');
              Workbk.WriteToFile(ExtractFilePath(inputPandF[filecount])+newfilename+'.xlsx',sfOOXML,True);   //Save the workbook in Directory from the input file
              Workbk.Free;
              FileContents.Free;
              inputPandF.Free;
              DelimitersList.Free;
              halt(1);
            end;
          end;
          LineasList.Clear;
        end;
      end;

      if (ChkboxGauss.Checked = False) then                                  //Get Atom Identifiers from other section than the coordinates etc. but non Gaussian input
      begin
        if (ChkboxAtomIdentifothersect.Checked = True) then
        begin
          FoundDelimitersList.Clear;
          firstline:=StrToInt(lbledtAtomIdentifotherline.Text)-1;
          for i:=0 to (NumberOfAtoms-1) do
          begin
            lengthmax:=firstline + NumberOfAtoms-1;
            if (((i + firstline) <= lengthmax) and ((i+firstline) <= (firstline+NumberOfAtoms-1))) then  //firstline will be increased from set to set
            begin
              line:=FileContents[i + firstline];                             //i+firstline is the number of the line to be parsed
              LineasList.Clear;

              if (FoundDelimitersList.Count = 0) then                        //Will only take place for the first line of the section -> we select the delimiters actually found from all encoded delimiters
              begin                                                          //a given section will be encoded the same way -> only do it once
                FindDelimiters(line, DelimitersList, FoundDelimitersList);
              end;

              SplitLineAsList(line, FoundDelimitersList, LineasList);        //Parsing function
              AtomIdentif[i]:=LineasList[colatomid-1];
              LineasList.Clear;
            end;
          end;
        end;
      end;

      if (ChkboxGauss.Checked = False) then                                  //Get charges from other section than the coordinates etc. but non Gaussian input
      begin
        if (ChkboxChargeothersect.Checked = True) then
        begin
          FoundDelimitersList.Clear;
          firstline:=StrToInt(lbledtChargeotherline.Text)-1;
          for i:=0 to (NumberOfAtoms-1) do
          begin
            lengthmax:=firstline + NumberOfAtoms-1;
            if (((i + firstline) <= lengthmax) and ((i+firstline) <= (firstline+NumberOfAtoms-1))) then  //firstline will be increased from set to set
            begin
              line:=FileContents[i + firstline];                             //i+firstline is the number of the line to be parsed
              LineasList.Clear;

              if (FoundDelimitersList.Count = 0) then                        //Will only take place for the first line of the section -> we select the delimiters actually found from all encoded delimiters
              begin                                                          //a given section will be encoded the same way -> only do it once
                FindDelimiters(line, DelimitersList, FoundDelimitersList);
              end;

              SplitLineAsList(line, FoundDelimitersList, LineasList);        //Parsing function
              Charge[i]:=LineasList[colatomcharg-1];
              LineasList.Clear;
            end;
          end;
        end;
      end;

      found:=False;
      if (ChkboxGauss.Checked=True) then                                     //Gaussian input firstline definition for other charges than Mulliken & atom identifiers
      begin
        trymulliken:=False;
        if ((ChkboxAPT.Checked=True) or (ChkboxNBO.Checked=True)) then       //APT or NBO
        begin
          FoundDelimitersList.Clear;
          k:=firstline;
          while ((found=False) and (k<=(FileContents.Count-1))) do
          begin
            if ((ChkboxAPT.Checked=True) and (AnsiContainsText(Trim(FileContents[k]),'apt atomic charges')=True)) then
            begin
              firstline:=k+2;
              found:=True;
            end;
            if ((ChkboxNBO.Checked=True) and (AnsiContainsText(Trim(FileContents[k]),'natural population analysis')=True)) then
            begin
              firstline:=k+6;
              found:=True;
            end;
            k:=k+1;
          end;

          if ((ChkboxAPT.Checked=True) and (k=FileContents.Count)) then      //Search terms for APT charges were not found
          begin                                                              //Search for new search terms for APT charges -> Form2
            Form2.Caption:='APT Search Terms';
            Form2.lbldescription.Caption:='No APT charges were found using the default search term.';
            Form2.btnContwithMulliken.Show;
            Form2.ShowModal;
            if (Form2.directlyMulliken=True) then trymulliken:=True;
            if (Form2.Resumeparsing=True) then
            begin
              firstline:=Form2.newsearchfirstline-1;
              colatomid:=Form2.newsearchcolatomid;
              colatomcharg:=Form2.newsearchcolatomcharg;
            end;
          end;

          if ((ChkboxNBO.Checked=True) and (k=FileContents.Count)) then      //Search terms for NBO charges were not found
          begin                                                              //Search for new search terms for NBO charges -> Form2
            Form2.Caption:='NBO Search Terms';
            Form2.lbldescription.Caption:='No NBO charges were found using the default search term.';
            Form2.btnContwithMulliken.Show;
            Form2.ShowModal;
            if (Form2.directlyMulliken=True) then
            begin
              trymulliken:=True;
              colatomid:=2;                                                  //Default for mulliken; stored value was read in GUI for NBO -> '1' instead of '2'
            end;
            if (Form2.Resumeparsing=True) then
            begin
              firstline:=Form2.newsearchfirstline-1;
              colatomid:=Form2.newsearchcolatomid;
              colatomcharg:=Form2.newsearchcolatomcharg;
            end;
          end;

          if ((Form2.Resumeparsing=True) or (found=True)) then
          begin
            for i:=0 to (NumberOfAtoms-1) do
            begin
              lengthmax:=firstline + NumberOfAtoms-1;
              if (((i + firstline) <= lengthmax) and ((i+firstline) <= (firstline+NumberOfAtoms-1))) then   //firstline will be increased from set to set
              begin
                line:=FileContents[i + firstline];                           //i+firstline is the number of the line to be parsed
                LineasList.Clear;

                if (FoundDelimitersList.Count = 0) then                      //Will only take place for the first line of the section -> we select the delimiters actually found from all encoded delimiters
                begin                                                        //a given section will be encoded the same way -> only do it once
                  FindDelimiters(line, DelimitersList, FoundDelimitersList);
                end;

                SplitLineAsList(line, FoundDelimitersList, LineasList);      //Parsing function
                AtomIdentif[i]:=LineasList[colatomid-1];
                Charge[i]:=LineasList[colatomcharg-1];
                LineasList.Clear;
              end;
            end;
          end;
        end;

        if ((trymulliken=True) or (ChkboxMull.Checked=True)) then            //Gaussian input firstline definition for charges (Mulliken) & atom identifiers
        begin
          found:=False;
          k:=firstline;
          nomulliken:=True;
          while ((found=False) and (k<=(FileContents.Count-1))) do
          begin
            if (AnsiContainsText(Trim(FileContents[k]),'mulliken atomic charges')=True) then
            begin
              firstline:=k+2;
              found:=True;
              nomulliken:=False;
            end;
            if (AnsiContainsText(Trim(FileContents[k]),'total atomic charges')=True) then
            begin
              firstline:=k+2;
              found:=True;
              nomulliken:=False;
            end;
            k:=k+1;
          end;

          if (nomulliken=True) then                                          //Search for new search terms for mulliken charges -> Form2
          begin
            Form2.Caption:='Mulliken Search Terms';
            Form2.lbldescription.Caption:='No Mulliken charges were found using the default search term.';
            Form2.btnContwithMulliken.Hide;
            Form2.ShowModal;
            firstline:=Form2.newsearchfirstline-1;
            colatomid:=Form2.newsearchcolatomid;
            colatomcharg:=Form2.newsearchcolatomcharg;
            nomulliken:=False;
          end;

          FoundDelimitersList.Clear;
          for i:=0 to (NumberOfAtoms-1) do
          begin
            lengthmax:=firstline + NumberOfAtoms-1;
            if (((i + firstline) <= lengthmax) and ((i+firstline) <= (firstline+NumberOfAtoms-1))) then  //firstline will be increased from set to set
            begin
              line:=FileContents[i + firstline];                             //i+firstline is the number of the line to be parsed
              LineasList.Clear;

              if (FoundDelimitersList.Count = 0) then                        //Will only take place for the first line of the section -> we select the delimiters actually found from all encoded delimiters
              begin                                                          //a given section will be encoded the same way -> only do it once
                FindDelimiters(line, DelimitersList, FoundDelimitersList);
              end;

              SplitLineAsList(line, FoundDelimitersList, LineasList);        //Parsing function
              AtomIdentif[i]:=LineasList[colatomid-1];
              if (ChkboxNoCharge.Checked=False) then
              begin
                Charge[i]:=LineasList[colatomcharg-1];
              end
              else
                Charge[i]:='';
              LineasList.Clear;
            end;
          end;
        end;
      end;

      for k:=0 to (NumberOfAtoms-1) do                                       //write the matrices/vectors: indexes: row, column, what-to-write. row & column begin at 0 -> 0,0 =A1
      begin
        Worksh.WriteNumber(k,1,StrToFloat(XCoord[k]));
        Worksh.WriteNumber(k,2,StrToFloat(YCoord[k]));
        Worksh.WriteNumber(k,3,StrToFloat(ZCoord[k]));
        if (ChkboxNoCharge.Checked=false) then
          Worksh.WriteNumber(k,5,StrToFloat(Charge[k]));

        hit:=False;                                                          //for an unknown atom (not in list)

        if (Chkboxatomidentletter.Checked=True) then                         //if input N, C, O etc. -> conversion into numbers for Excel
        begin
          for l:=0 to (Length(AtomNameRadius)-2) do                          //-2 b/c last one is 'Other'
          begin
            if (AtomIdentif[k]=AtomNameRadius[l,1]) then
            begin
              hit:=True;
              Worksh.WriteCellValueAsString(k,0,AtomIdentif[k]);             //write atom symbol
              Worksh.WriteNumber(k,7,StrToInt(AtomNameRadius[l,0]));         //write atom def number
              Worksh.WriteNumber(k,4,StrToFloat(AtomNameRadius[l,2]));       //write radius
              summedmass:=summedmass + StrToInt(AtomNameRadius[l,0]);
            end;
          end;
        end;

        if (Chkboxatomidentinteg.Checked=True) then
        begin
          for l:=0 to (Length(AtomNameRadius)-2) do                          //"other" will be associates to 400 as atom identifier
          begin
            if AtomNameRadius[l,0]=AtomIdentif[k] then
            begin
              hit:=True;
              Worksh.WriteCellValueAsString(k,0,AtomNameRadius[l,1]);        //write atom symbol
              Worksh.WriteNumber(k,7,StrToInt(AtomIdentif[k]));              //write atom def number
              Worksh.WriteNumber(k,4,StrToFloat(AtomNameRadius[l,2]));       //write radius
              summedmass:=summedmass + StrToInt(AtomIdentif[k]);
            end;
          end;
        end;

        if (hit=False) then                                                  //if an atom in unknown (not listed) -> write "other" & show a message once
        begin
          Worksh.WriteCellValueAsString(k,0,AtomNameRadius[(Length(AtomNameRadius)-1),1]);        //write atom symbol
          Worksh.WriteNumber(k,7,StrToInt(AtomNameRadius[(Length(AtomNameRadius)-1),0]));         //write atom def number
          Worksh.WriteNumber(k,4,StrToFloat(AtomNameRadius[(Length(AtomNameRadius)-1),2]));       //write radius
          summedmass:=summedmass + StrToInt(AtomNameRadius[(Length(AtomNameRadius)-1),0]);
          if (sheetnum=0) then                                               //Message if "other" atom found; write only once (sheetnum=0)
          begin
               case QuestionDlg ('Attention: Atom identifier','Unknown atom identifier encountered.'
                   +sLineBreak+sLineBreak+'It is being encoded as'
                   +sLineBreak+'"Other"'
                   +sLineBreak+'Default mass: 400'
                   +sLineBreak+'Default radius: 2'
                   +sLineBreak+sLineBreak+'Line number '+IntToStr(k+1),mtCustom,[mrYes,'Yes, I know', mrNo, 'Please abort the conversion and Save', 'IsDefault'],'') of
                   mrNo: Stopping:=True;
               end;
            if (Stopping=True) then
            begin
              newfilename:=ChangeFileExt(ExtractFileName(inputPandF[filecount]),'');
              if CBFormat.ItemIndex=0 then Workbk.WriteToFile(ExtractFilePath(inputPandF[filecount])+newfilename+'.xls',sfExcel8,True);     //Save the workbook in Directory from the input file
              if CBFormat.ItemIndex=1 then Workbk.WriteToFile(ExtractFilePath(inputPandF[filecount])+newfilename+'.xlsx',sfOOXML,True);
              if CBFormat.ItemIndex=2 then Workbk.WriteToFile(ExtractFilePath(inputPandF[filecount])+newfilename+'.ods',sfOpenDocument,True);
              if CBFormat.ItemIndex=3 then Workbk.WriteToFile(ExtractFilePath(inputPandF[filecount])+newfilename+'.csv',sfCSV,True);
              Workbk.Free;
              FileContents.Free;
              inputPandF.Free;
              DelimitersList.Free;
              halt(1);
            end;
          end;
        end;
        hit:=False;                                                          //initialize hit for next atoms/atom identifiers
      end;

      Worksh.WriteCellValueAsString(0,6,'Total Charge');
      Worksh.WriteCellValueAsString(2,6,'Total Mass');

      if (lbledtcharge.Text<>'') then
      begin
        chargetot:= StrToInt(lbledtcharge.Text);
        Worksh.WriteNumber(1,6,chargetot);                                   //write total charge in G2 if encoded in GUI
      end;
      if (lbledtmass.Text='') or (lbledtmass.Text='0') then
      begin
        Worksh.WriteNumber(3,6,summedmass);                                  //calculate & write total mass if not encoded in GUI (!Attention for 400 atom!)
      end
      else
      begin
        mass:=StrToFloat(lbledtmass.Text);
        Worksh.WriteNumber(3,6,mass);                                        //write total mass if encoded in GUI
      end;

      if (ChkboxAll.Checked=True) then                                       //continue parsing if multiple structures -> new def for firstline
      begin
        firstline:=firstline + NumberOfAtoms + emptylines;
      end;

      if (ChkboxSelect.Checked=True) then                                    //continue parsing if multiple selected structures -> new def for firstline; selectcount is counter for sets max:SelectContents.Count-1; -1 b/c 1 line description
      begin
        selectcount:=selectcount+1;
        if (selectcount<=(SelectContents.Count-1)) then
        begin
          firstline:= (((StrToInt(SelectContents[selectcount])-1)*NumberOfAtoms) + ((StrToInt(SelectContents[selectcount])-1)*emptylines) + (StrToInt(lbledtfirstline.Text)-1));
          //ShowMessage('New first line: '+IntToStr(firstline));
        end;
      end;
    end;

    FoundDelimitersList.Clear;
    LineasList.Clear;
    FileContents.Clear;

    newfilename:=ChangeFileExt(ExtractFileName(inputPandF[filecount]),'');   //Save the workbook in Directory from the input file   //Output file formats
    if CBFormat.ItemIndex=0 then Workbk.WriteToFile(ExtractFilePath(inputPandF[filecount])+newfilename+'.xls',sfExcel8,True);
    if CBFormat.ItemIndex=1 then Workbk.WriteToFile(ExtractFilePath(inputPandF[filecount])+newfilename+'.xlsx',sfOOXML,True);
    if CBFormat.ItemIndex=2 then Workbk.WriteToFile(ExtractFilePath(inputPandF[filecount])+newfilename+'.ods',sfOpenDocument,True);
    if CBFormat.ItemIndex=3 then Workbk.WriteToFile(ExtractFilePath(inputPandF[filecount])+newfilename+'.csv',sfCSV,True);
    Workbk.Free;
  end;

  if (ChkboxSelect.Checked=True) then
  begin
    SelectContents.Clear;
    SelectContents.Free;
  end;

  FileContents.Free;
  FoundDelimitersList.Free;
  LineasList.Free;

  ShowMessage('Parsing finished...enjoy');
end;

procedure TForm1.BtnCopyFromAtomIdentifClick(Sender: TObject);               //Copy other section line number for Charge from Atom Identifier if the same
begin
  lbledtChargeotherline.Text:=lbledtAtomIdentifotherline.Text;
end;

procedure WriteToMemo(Memo:TMemo;inputfiles:TstringList;inputselectfile:string);  //Write all input files in Memo
var
  i: integer;
begin
  Memo.Clear;                                                                //Begin everytime from scratch: if reloaded file -> will not be written twice into memobox
  if (Form1.ChkboxInputFile.Checked = True) then
  begin
    for i:=0 to (inputfiles.Count-1) do
    begin
      Memo.Lines.Add('IN '+IntToStr(i+1));
      Memo.Lines.Add(inputfiles[i]);
    end;
    Form1.lblLoadedFiles.Caption:='Loaded Files: '+IntToStr(inputfiles.Count);
  end;
  if (Form1.ChkboxSelect.Checked = True) then
  begin
    Memo.Lines.Add('SELECTION');
    Memo.Lines.Add(inputselectfile);
    Form1.lblLoadedFiles.Caption:='Loaded Files: '+IntToStr(inputfiles.Count+1);
  end;

  Memo.SelStart:=0;                                                        //Show at line 1
end;

procedure TForm1.BtnBrowseInputFileClick(Sender: TObject);                   //Browse to get input files name and path (files from same directory)
var
  i:integer;
  OpenFileBrow:TOpenDialog;
begin
  OpenFileBrow:=TOpenDialog.Create(self);
  //OpenFileBrow.Filter:='Text files only (.txt)|*.txt;*.TXT';               //restrict to only open .txt files
  OpenFileBrow.Title:='Open the input file(s) which need(s) parsing';
  OpenFileBrow.Options:=[ofAllowMultiSelect];

  if (OpenFileBrow.Execute) then
  begin
    inputPandF.Clear;
    for i:=0 to (OpenFileBrow.Files.Count-1) do
    begin
      inputPandF.Add(OpenFileBrow.Files.Strings[i])
    end;
    ChkboxInputFile.Checked:=True;
    WriteToMemo(MemoDisplayInputName,inputPandF,selectPandF);
  end
  else
  begin
    ChkboxInputFile.Checked:=False;
    BtnAddmorefiles.Enabled:=False;
  end;

  {if (inputPandF.Count<>0) then                                              //Add files from different folder, keeping the other files as well
  begin
    BtnAddmorefiles.Enabled:=True;
  end;               }

  OpenFileBrow.Free;
end;

procedure TForm1.BtnAddmorefilesClick(Sender: TObject);                     //Add files from different folder, keeping the other files as well
var
  i:integer;
  OpenmoreFileBrow:TOpenDialog;
begin
  OpenmoreFileBrow:=TOpenDialog.Create(self);
  //OpenFileBrow.Filter:='Text files only (.txt)|*.txt;*.TXT';               //restrict to only open .txt files
  OpenmoreFileBrow.Title:='Open the input file which needs parsing';
  OpenmoreFileBrow.Options:=[ofAllowMultiSelect];

  if (OpenmoreFileBrow.Execute) then
  begin
    for i:=0 to (OpenmoreFileBrow.Files.Count-1) do
    begin
      inputPandF.Add(OpenmoreFileBrow.Files.Strings[i])
    end;
    ChkboxInputFile.Checked:=True;
    WriteToMemo(MemoDisplayInputName,inputPandF,selectPandF);
  end
  else
  begin
    ChkboxInputFile.Checked:=False;
  end;

  OpenmoreFileBrow.Free;

end;

procedure TForm1.BtnBrowseInputFileMouseEnter(Sender: TObject);            //ShowHint for Browse Button
begin
  BtnBrowseInputFile.ShowHint:=True;
  BtnBrowseInputFile.Hint:='Select input file(s) from same directory, subjected to identical parsing parameters.'
                       +sLineBreak+'Clears all previously selected files.'
                       +sLineBreak+'If parsing doesn''t work, try .txt file format.';
end;

procedure TForm1.BtnAddmorefilesMouseEnter(Sender: TObject);               //ShowHint for AddmoreFiles Button
begin
  BtnAddmoreFiles.ShowHint:=True;
  BtnAddmoreFiles.Hint:='Select more input file(s) from different directories, subjected to identical parsing parameters.'
                       +sLineBreak+'Does not clear previously selected files.'
                       +sLineBreak+'If parsing doesn''t work, try .txt file format.';
end;

procedure TForm1.btnInfoClick(Sender: TObject);                            //Info Button
begin
  ShowMessage(
  '** If parsing your input(s) doesn''t work, try a ".txt" input file format. Several inputs can be loaded at the same time if the parsing parameters are identical.'

  +sLineBreak+ '** You can put the total CHARGE state and the total MASS of your ion in the "Total Charge" and "Total Mass" boxes. '
  +sLineBreak+ 'They are OPTIONAL. The charge must be integer; the mass can be real.'
  + ' You can leave the boxes blank. The MASS will then be calculated automatically. ! SPECIAL ATOMS will be given the atomic number "400" !'

  +sLineBreak+ '** ATOMS can be defined using LETTERS (H, C, N, O,...). If using ATOMIC NUMBERS, please make sure they are INTEGER values; the digits should be rounded to the nearest integer value.'

  +sLineBreak+ '** The number of structures/sets of coordinates does not have to be given if using a file with a SELECTION of STRUCTURES to be parsed.'
  +sLineBreak+'The file can only be in ".txt" format and will be read starting @line#2. Please encode one structure/set of coordinates per line.'

  +sLineBreak+ '** GAUSSIAN inputs are read even if no geometry optimization was performed. If no optimized geometry is found, the input structure will be read. '
  +'Do not change any automatically encoded parameters.'

  +sLineBreak+ '** MOBCAL inputs can be parsed together even if not containing the same number of atoms. The parameters are read in the mobcal input.'
  +sLineBreak+ 'Please do not forget to change the atom identifiers from real to integer values.'

  +sLineBreak+ '** ATOM IDENTIFIERS and CHARGES can be read from DIFFERENT SECTIONS of the input file. You need to provide the line number(s) of the file where the atom identifiers/charges begin being described.'
  + ' You need to provide as well the column number of the identifiers/charges. Begin line counting considering the very first line of the input as line "1".'
  +'Charges can be ignored (not parsed) by choosing "N/A".'

  +sLineBreak+'** You can RELOAD the parameters used for your last encoding by clicking on the "Load last parameters" button.'

  +sLineBreak+'** You can change the DELIMITERS LIBRARY in the file "Lib_Delimiters.par". Only use 1 delimiter per line. The first line is a file description.'
  +sLineBreak+'You can add/modify/change ATOM DESCRIPTIONS & VDW RADII in the file "Lib_Atoms_VDW.par". The last descriptor must remain the descriptor "Other". The file is tab-delimited containing 2 lines of file descriptions.'

  +sLineBreak+'** A detailed tutorial of ParsIMoS can be found in the program installation files/application bundle.');


  ShowMessage('ParsIMoS is distributed under Apache License, Version 2.0.'
  +sLineBreak+sLineBreak+ 'University of Liège, Belgium'
  +sLineBreak+ 'Jean R. N. Haler (FRIA, F.R.S.-FNRS), jean.haler'+char(64)+'ulg.ac.be'
  +sLineBreak+ 'Christopher Kune, c.kune'+char(64)+'ulg.ac.be'
  +sLineBreak+ 'Dr. Johann Far, johann.far'+char(64)+'ulg.ac.be'
  +sLineBreak+ 'Prof. Edwin De Pauw, e.depauw'+char(64)+'ulg.ac.be'
  +sLineBreak+sLineBreak+ 'parsimos'+char(64)+'outlook.com');
end;

procedure TForm1.btnloadlastparamClick(Sender: TObject);                   //Load last parameters used for encoding
var
  Paramfile:text;
  i,j,counter, inputfilecount: integer;
  Params,List: TStringList;
  car,temp,res:string;
  gotloaded:boolean;
begin
  AssignFile(Paramfile,'Last_parameters.par');                             //Backup of last parameters used for encoding
  Reset(Paramfile);                                                        //opens file; 3 lines of comments
  Params:= TStringList.Create;
  List:= TStringList.Create;
  Params.Clear;
  List.Clear;

  Params.LoadFromFile('Last_parameters.par');
  j:=Params.Count-3;
  counter:=1;
  for i:=0 to (j-1) do
  begin
    res:='';
    car:=Copy(Params.Strings[i+3],counter,1);                              //3 lines of comments -> i+3
    while (car <> chr(9)) do
    begin
      counter:=counter+1;
      car:=Copy(Params.Strings[i+3],counter,1);
    end;
    while ((car=chr(9)) and ((counter+1)<=Length(Params.Strings[i+3]))) do
    begin
      counter:=counter+1;
      temp:=Copy(Params.Strings[i+3],counter,1);
      res:=res+temp;
    end;

    List.Add(res);
    counter:=1;
  end;

  inputfilecount:=StrToInt(List[0]);                                     //path + filename
  gotloaded:=False;
  inputPandF.Clear;
  for i:=0 to (inputfilecount-1) do
  begin
    if (FileExists(List[i+1]) = True) then                               //check if file is still in same directory
    begin
      inputPandF.Add(List[i+1]);
      gotloaded:=True;
    end
    else
    begin
      ShowMessage('Unable to load input file.'+sLineBreak+List[i+1]);
    end;
  end;

  if (gotloaded = True) then
  begin
    ChkboxInputFile.Checked:=True;
  end;

  CBFormat.ItemIndex:=     StrToInt(List[inputfilecount+1]);
  ChkboxGauss.Checked:=StrToBool(List[inputfilecount+2]);
  ChkboxMull.Checked:=StrToBool(List[inputfilecount+3]);
  ChkboxAPT.Checked:=StrToBool(List[inputfilecount+4]);
  ChkboxNBO.Checked:=StrToBool(List[inputfilecount+5]);
  lbledtnumatoms.Text:=    List[inputfilecount+6];
  lbledtmass.Text:=        List[inputfilecount+7];
  lbledtcharge.Text:=      List[inputfilecount+8];
  ChkboxAll.Checked:=StrToBool(List[inputfilecount+9]);
  //ChkboxSelect.Checked:=StrToBool(List[10]);
  lbledtfirstline.Text:=   List[inputfilecount+11];
  lbledtnumsets.Text:=     List[inputfilecount+12];
  lbledtnumcoltot.Text:=   List[inputfilecount+13];
  lbledtxcoordcol.Text:=   List[inputfilecount+14];
  lbledtycoordcol.Text:=   List[inputfilecount+15];
  lbledtzcoordcol.Text:=   List[inputfilecount+16];
  lbledtatomidentcol.Text:=List[inputfilecount+17];
  Chkboxatomidentletter.Checked:=StrToBool(List[inputfilecount+18]);
  Chkboxatomidentinteg.Checked:=StrToBool(List[inputfilecount+19]);
  ChkboxAtomIdentifsamesect.Checked:=StrToBool(List[inputfilecount+20]);
  ChkboxAtomIdentifothersect.Checked:=StrToBool(List[inputfilecount+21]);
  lbledtAtomIdentifotherline.Text:=List[inputfilecount+22];
  lbledtatomchargcol.Text:=List[inputfilecount+23];
  ChkboxChargesamesect.Checked:=StrToBool(List[inputfilecount+24]);
  ChkboxChargeothersect.Checked:=StrToBool(List[inputfilecount+25]);
  lbledtChargeotherline.Text:=List[inputfilecount+26];
  lbledtemptylin.Text:=    List[inputfilecount+27];
  Chkboxmobcal.Checked:=StrToBool(List[inputfilecount+28]);
  ChkboxNoCharge.Checked:=StrToBool(List[inputfilecount+29]);

  if (List[inputfilecount+30] = '') then
  begin
    selectPandF:='';
    ChkboxSelect.Checked:=False;
  end
  else
  begin
    if (FileExists(List[inputfilecount+30]) = True) then                      //check if file is still in same directory
    begin
      selectPandF:=List[inputfilecount+30];                                   //path + filename
      ChkboxSelect.Checked:=True;
    end
    else
    begin
      selectPandF:='';
      ShowMessage('Unable to load the file containing the selection of sets of coordinates.'+sLineBreak+selectPandF);
    end;
  end;

  if ((gotloaded = True) or (selectPandF <> '')) then
  begin
    WriteToMemo(MemoDisplayInputName,inputPandF,selectPandF);
  end;

  gotloaded:=False;

  Params.Clear;
  List.Clear;
  Params.Free;
  List.Free;
  CloseFile(Paramfile);
end;

procedure TForm1.BtnBrowseSelectionFileClick(Sender: TObject);                              //Get file with frame selection
var
  OpenSelectionBrow:TOpenDialog;
begin
  OpenSelectionBrow:=TOpenDialog.Create(self);
  OpenSelectionBrow.Filter:='Text files only (.txt)|*.txt;*.TXT';            //restrict to only open .txt files
  OpenSelectionBrow.Title:='Open the file containing the selected sets of coordinates';

  if (OpenSelectionBrow.Execute) then
  begin
    selectPandF:=OpenSelectionBrow.FileName;
    ChkboxSelect.Checked:=True;
    WriteToMemo(MemoDisplayInputName,inputPandF,selectPandF);
  end
  else
  begin
    ChkboxSelect.Checked:=False;
  end;

  OpenSelectionBrow.Free;
end;

procedure TForm1.BtnBrowseSelectionFileMouseEnter(Sender: TObject);           //ShowHint for Frame Selection Button
begin
  BtnBrowseSelectionFile.ShowHint:=True;
  BtnBrowseSelectionFile.Hint:='The file can only be in ".txt" format and will be read starting @line#2.'
                                    +sLineBreak+'Please encode one structure/set of coordinates per line.';
end;

procedure TForm1.CBFormatChange(Sender: TObject);
begin
  if CBFormat.ItemIndex=0 then btnConvert.Caption:='Convert to .xls';
  if CBFormat.ItemIndex=1 then btnConvert.Caption:='Convert to .xlsx';
  if CBFormat.ItemIndex=2 then btnConvert.Caption:='Convert to .ods';
  if CBFormat.ItemIndex=3 then btnConvert.Caption:='Convert to .csv';
end;

procedure TForm1.ChkboxAllChange(Sender: TObject);
begin
  if ChkboxAll.Checked=True then
  begin
    ChkboxSelect.Checked:=False;
    lbledtnumsets.Color:=clDefault;
    lbledtnumsets.Text:='';
  end;
  if ChkboxGauss.Checked=True then
    ChkboxAll.Checked:=False;
end;

procedure TForm1.ChkboxSelectChange(Sender: TObject);                         //Chkbox Frame Selection
begin
  if (ChkboxSelect.Checked=False) then
  begin
    ShowMessage('No file with a selection of sets of coordinates was loaded.');
    ChkboxAll.Checked:=True;
    ChkboxSelect.Enabled:=False;
    WriteToMemo(MemoDisplayInputName,inputPandF,selectPandF);
  end;

  if (ChkboxSelect.Checked=True) then
  begin
    if (MemoDisplayInputName.Visible=False) then
    begin
      lblLoadedFiles.Show;
      MemoDisplayInputName.Show;
    end;
    ChkboxSelect.Enabled:=True;
    ChkboxAll.Checked:=False;
    lbledtnumsets.Color:=clGrayText;
    lbledtnumsets.Text:='0';
  end;
  if ChkboxGauss.Checked=True then
    ChkboxSelect.Checked:=False;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);   //Free memory
begin
  DelimitersList.Free;
  inputPandF.Free;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  FileVerInfo: TFileVersionInfo;
  atomparIN, delimIN:text;
  atompar, delimiterinput, linetoparse, dir{, controlstring}:string;
  Templist, LineList:TStringList;
  i:integer;
begin
  lblpercentage.Parent:=ProgressBar1;                                          //Put the label showing the % in the middle of the progressbar
  lblpercentage.AutoSize:=False;
  lblpercentage.Transparent:=True;
  lblpercentage.Top:=0;
  lblpercentage.Left:=0;
  lblpercentage.Width:=ProgressBar1.ClientWidth;
  lblpercentage.Height:= ProgressBar1.ClientHeight;
  lblpercentage.Alignment:=taCenter;
  lblpercentage.Layout:=tlCenter;
  lblpercentage.Caption:='';

  inputPandF:=TStringList.Create;

  FileVerInfo:=TFileVersionInfo.Create(nil);
  try
    FileVerInfo.FileName:=paramstr(0);
    FileVerInfo.ReadFileInfo;
    {writeln('File description: ',FileVerInfo.VersionStrings.Values['FileDescription']);
    writeln('Internal name: ',FileVerInfo.VersionStrings.Values['InternalName']);
    writeln('Legal copyright: ',FileVerInfo.VersionStrings.Values['LegalCopyright']);
    writeln('Original filename: ',FileVerInfo.VersionStrings.Values['OriginalFilename']);
    writeln('Product name: ',FileVerInfo.VersionStrings.Values['ProductName']);
    writeln('File version: ',FileVerInfo.VersionStrings.Values['ProductVersion']);}
    lblcompany.Caption:=FileVerInfo.VersionStrings.Values['CompanyName'];
    lblversion.Caption:=' v. ' + FileVerInfo.VersionStrings.Values['FileVersion'];
  finally
    FileVerInfo.Free;
  end;

  CBFormat.Items.Add('.xls');                           //binary xls format used by Excel ("BIFF" = "Binary Interchange File Format") -> sfExcel8
  CBFormat.Items.Add('.xlsx');                          //newer xlsx format introduced by Excel2007 -> sfOOXML
  CBFormat.Items.Add('.ods');                           //OpenOffice/LibreOffice -> sfOpenDocument
  CBFormat.Items.Add('.csv');                           //comma-delimited text files; they can be understood by any text editor and all spreadsheet programs, but do not contain formatting information -> sfCSV
  CBFormat.ItemIndex:=1;

  dir:=ProgramDirectory;                                //directory of the parameter files = directory of the .exe
  SetCurrentDir(dir);

  delimiterinput:=('Lib_Delimiters.par');               //Load Delimiter library
  AssignFile(delimIN,delimiterinput);
  Reset(delimIN);                                       //opens file & reads parameters for atom identification & radii
  DelimitersList:=TStringList.Create;
  DelimitersList.Clear;
  DelimitersList.LoadFromFile(delimiterinput);
  DelimitersList.Delete(0);                             //Delete the line of description
  {controlstring:='';
  for i:=0 to (DelimitersList.Count-1) do
  begin
    controlstring:=controlstring+'d'+DelimitersList[i];
  end;
  ShowMessage('All delimiters: '+controlstring); }
  CloseFile(delimIN);


  atompar:=('Lib_Atoms_VDW.par');                       //Load Atom parameter library
  AssignFile(atomparIN,atompar);
  Reset(atomparIN);                                     //opens file & reads parameters for atom identification & radii
  Templist:=TStringList.Create;
  Templist.Clear;
  Templist.LoadFromFile(atompar);
  SetLength(AtomNameRadius,Templist.Count-2,3);         //Templist.count-2 b/c 2-line description; 3 b/c 3 parameter columns                                                       //possibility to add new atoms etc.
  LineList:=TStringList.Create;
  LineList.Clear;
  for i:=0 to (Templist.Count-3) do                     //Templist.count-3 b/c 2-line description
  begin
    linetoparse:=Templist[i+2];                         //+2 b/c 2-line description
    SplitLineAsList(linetoparse,DelimitersList,LineList);  //use DelimitersList and not FoundDelimitersList in case someone did not encode correctly
    AtomNameRadius[i,0]:=LineList[0];                   //Integer Atom Identifier              [line, column]
    AtomNameRadius[i,1]:=LineList[1];                   //Letter Atom Identifier
    AtomNameRadius[i,2]:=LineList[2];                   //VDW Radius Atom
    LineList.Clear;
  end;
  LineList.Clear;
  LineList.Free;
  CloseFile(atomparIN);
  Templist.Clear;
  Templist.Free;
  {controlstring:=AtomNameRadius[0,0]+' '+AtomNameRadius[0,1]+' '+AtomNameRadius[0,2];
  ShowMessage('First line Atom parameters: '+controlstring);
  controlstring:=AtomNameRadius[Length(AtomNameRadius)-1,0]+' '+AtomNameRadius[Length(AtomNameRadius)-1,1]+' '+AtomNameRadius[Length(AtomNameRadius)-1,2];
  ShowMessage('Last line Atom parameters: '+controlstring); }

end;

procedure TForm1.lbledtAtomIdentifotherlineMouseEnter(Sender: TObject);       //ShowHint for atom identifiers in other section; give line
begin
  lbledtAtomIdentifotherline.ShowHint:=True;
  lbledtAtomIdentifotherline.Hint:='Begin counting considering the very first line of the input as line "1"'
end;

procedure TForm1.lbledtChargeotherlineMouseEnter(Sender: TObject);             //ShowHint for charge in other section; give line
begin
  lbledtChargeotherline.ShowHint:=True;
  lbledtChargeotherline.Hint:='Begin counting considering the very first line of the input as line "1"'
end;

procedure TForm1.ChkboxatomidentintegChange(Sender: TObject);
begin
  if Chkboxatomidentinteg.Checked=True then
  begin
    Chkboxatomidentletter.Checked:=False;
    Label5.Show;
  end;
end;

procedure TForm1.ChkboxatomidentletterChange(Sender: TObject);
begin
  if Chkboxatomidentletter.Checked=True then
  begin
    Chkboxatomidentinteg.Checked:=False;
    Label5.Hide;
  end;
end;

procedure TForm1.ChkboxChargeothersectChange(Sender: TObject);
begin
  if (ChkboxChargeothersect.Checked=True) then
  begin
    ChkboxChargesamesect.Checked:=False;
    ChkboxNoCharge.Checked:=False;
    lbledtChargeotherline.Show;
    BtnCopyFromAtomIdentif.Show;
  end
end;

procedure TForm1.ChkboxChargesamesectChange(Sender: TObject);
begin
  if (ChkboxChargesamesect.Checked=True) then
  begin
    ChkboxChargeothersect.Checked:=False;
    ChkboxNoCharge.Checked:=False;
    lbledtChargeotherline.Hide;
    lbledtChargeotherline.Text:='';
    BtnCopyFromAtomIdentif.Hide;
  end
end;

procedure TForm1.ChkboxGaussChange(Sender: TObject);                       //GUI encoding for Gaussian inputs
begin
  if ChkboxGauss.Checked=true then
  begin
    ChkboxMull.Visible:=true;
    ChkboxAPT.Visible:=true;
    ChkboxNBO.Visible:=true;
    Chkboxmobcal.Visible:=False;
  end;
  if ChkboxGauss.Checked=false then
  begin
    ChkboxMull.Visible:=false;
    ChkboxAPT.Visible:=false;
    ChkboxNBO.Visible:=false;
    Chkboxmobcal.Visible:=True;
  end;

  if ChkboxGauss.Checked=true then
  begin
    ChkboxAll.Checked:=False;
    ChkboxSelect.Checked:=False;
    Chkboxmobcal.Checked:=False;
    lbledtfirstline.Text:='1';
    lbledtnumsets.Text:='1';
    lbledtnumcoltot.Text:='6';
    lbledtxcoordcol.Text:='0';
    lbledtycoordcol.Text:='0';
    lbledtzcoordcol.Text:='0';
    lbledtatomidentcol.Text:='2';
    Chkboxatomidentletter.Checked:=true;
    Chkboxatomidentinteg.Checked:=false;
    lbledtatomchargcol.Text:='3';
    ChkboxAtomIdentifsamesect.Checked:=False;
    ChkboxAtomIdentifothersect.Checked:=True;
    lbledtAtomIdentifotherline.Text:='0';
    lbledtemptylin.Text:='0';
    ChkboxChargesamesect.Checked:=False;
    ChkboxChargeothersect.Checked:=True;
    lbledtChargeotherline.Text:='0';
    lbledtfirstline.Color:=clGray;
    lbledtnumsets.Color:=clGray;
    lbledtnumcoltot.Color:=clGray;
    lbledtnumcoltot.Color:=clGray;
    lbledtxcoordcol.Color:=clGray;
    lbledtycoordcol.Color:=clGray;
    lbledtzcoordcol.Color:=clGray;
    lbledtatomidentcol.Color:=clGray;
    lbledtatomchargcol.Color:=clGray;
    lbledtemptylin.Color:=clGray;
    lbledtAtomIdentifotherline.Color:=clGray;
    lbledtChargeotherline.Color:=clGray;
  end;

  if ChkboxGauss.Checked=false then
  begin
    ChkboxAll.Checked:=True;
    lbledtfirstline.Text:='';
    lbledtnumsets.Text:='';
    lbledtnumcoltot.Text:='5';
    lbledtxcoordcol.Text:='';
    lbledtycoordcol.Text:='';
    lbledtzcoordcol.Text:='';
    lbledtatomidentcol.Text:='';
    Chkboxatomidentletter.Checked:=true;
    Chkboxatomidentinteg.Checked:=false;
    ChkboxAtomIdentifsamesect.Checked:=True;
    ChkboxAtomIdentifothersect.Checked:=False;
    lbledtAtomIdentifotherline.Text:='';
    lbledtatomchargcol.Text:='';
    ChkboxChargesamesect.Checked:=True;
    ChkboxChargeothersect.Checked:=False;
    lbledtChargeotherline.Text:='';
    lbledtemptylin.Text:='1';
    lbledtfirstline.Color:=clDefault;
    lbledtnumsets.Color:=clDefault;
    lbledtnumcoltot.Color:=clDefault;
    lbledtnumcoltot.Color:=clDefault;
    lbledtxcoordcol.Color:=clDefault;
    lbledtycoordcol.Color:=clDefault;
    lbledtzcoordcol.Color:=clDefault;
    lbledtatomidentcol.Color:=clDefault;
    lbledtatomchargcol.Color:=clDefault;
    lbledtemptylin.Color:=clDefault;
    lbledtAtomIdentifotherline.Color:=clDefault;
    lbledtChargeotherline.Color:=clDefault;
  end;

end;

procedure TForm1.ChkboxInputFileChange(Sender: TObject);                   //Check uncheck input file
begin
  if (ChkboxInputFile.Checked=False) then
  begin
    ShowMessage('No input file selected.');
    BtnAddmorefiles.Enabled:=False;
    ChkboxInputFile.Enabled:=False;
    MemoDisplayInputName.Hide;
    MemoDisplayInputName.Clear;
    lblLoadedFiles.Hide;
  end;
  if (ChkboxInputFile.Checked=True) then
  begin
    MemoDisplayInputName.Show;
    lblLoadedFiles.Show;
    ChkboxInputFile.Enabled:=True;
    BtnAddmorefiles.Enabled:=True;
  end;
end;

procedure TForm1.ChkboxmobcalChange(Sender: TObject);
begin
  if (Chkboxmobcal.Checked=True) then
  begin
    lbledtnumatoms.Text:='0';            //will be read in input for mobcal
    lbledtnumatoms.Color:=clGray;
    lbledtfirstline.Text:='7';
    lbledtnumsets.Text:='0';             //will be read in input for mobcal
    lbledtnumsets.Color:=clGray;
    lbledtnumcoltot.Text:='5';
    lbledtxcoordcol.Text:='1';
    lbledtycoordcol.Text:='2';
    lbledtzcoordcol.Text:='3';
    lbledtatomidentcol.Text:='4';
    Chkboxatomidentinteg.Checked:=True;
    ChkboxAtomIdentifsamesect.Checked:=True;
    lbledtatomchargcol.Text:='5';
    ChkboxChargesamesect.Checked:=True;
    lbledtemptylin.Text:='1';
    ChkboxGauss.Checked:=False;
    ChkboxAll.Checked:=True;
  end;
  if (Chkboxmobcal.Checked=False) then
  begin
    lbledtnumatoms.Text:='';
    lbledtnumatoms.Color:=clDefault;
    lbledtfirstline.Text:='';
    lbledtnumsets.Text:='';
    lbledtnumsets.Color:=clDefault;
    lbledtnumcoltot.Text:='';
    lbledtxcoordcol.Text:='';
    lbledtycoordcol.Text:='';
    lbledtzcoordcol.Text:='';
    lbledtatomidentcol.Text:='';
    Chkboxatomidentinteg.Checked:=True;
    ChkboxAtomIdentifsamesect.Checked:=True;
    lbledtatomchargcol.Text:='';
    ChkboxChargesamesect.Checked:=True;
    lbledtemptylin.Text:='1';
  end;
end;

procedure TForm1.ChkboxMullChange(Sender: TObject);
begin
  if ChkboxMull.Checked=true then
  begin
    ChkboxNBO.Checked:=false;
    ChkboxAPT.Checked:=false;
    ChkboxNoCharge.Checked:=false;
    lbledtatomidentcol.Text:='2';        //Default for other charges, e.g. APT and Mulliken
  end;
end;

procedure TForm1.ChkboxAPTChange(Sender: TObject);
begin
  if ChkboxAPT.Checked=true then
  begin
    ChkboxMull.Checked:=false;
    ChkboxNBO.Checked:=false;
    ChkboxNoCharge.Checked:=false;
    lbledtatomidentcol.Text:='2';        //Default for other charges, e.g. APT and Mulliken
  end;
end;

procedure TForm1.ChkboxAtomIdentifothersectChange(Sender: TObject);
begin
  if (ChkboxAtomIdentifothersect.Checked=True) then
  begin
    ChkboxAtomIdentifsamesect.Checked:=False;
    lbledtAtomIdentifotherline.Show;
  end
  else
    ChkboxAtomIdentifsamesect.Checked:=True;
end;

procedure TForm1.ChkboxAtomIdentifsamesectChange(Sender: TObject);
begin
  if (ChkboxAtomIdentifsamesect.Checked=True) then
  begin
    ChkboxAtomIdentifothersect.Checked:=False;
    lbledtAtomIdentifotherline.Hide;
    lbledtAtomIdentifotherline.Text:='';
  end
  else
    ChkboxAtomIdentifothersect.Checked:=True;
end;

procedure TForm1.ChkboxNBOChange(Sender: TObject);
begin
  if ChkboxNBO.Checked=true then
  begin
    ChkboxMull.Checked:=false;
    ChkboxAPT.Checked:=false;
    ChkboxNoCharge.Checked:=false;
    lbledtatomidentcol.Text:='1';
  end;
end;

procedure TForm1.ChkboxNoChargeChange(Sender: TObject);
begin
  if ChkboxNoCharge.Checked=True then
  begin
    ChkboxMull.Checked:=False;
    ChkboxAPT.Checked:=False;
    ChkboxNBO.Checked:=False;
    ChkboxChargeothersect.Checked:=False;
    ChkboxChargesamesect.Checked:=False;
    lbledtChargeotherline.Hide;
    lbledtChargeotherline.Text:='';
    BtnCopyFromAtomIdentif.Hide;
    lbledtatomchargcol.Text:='0';
    lbledtatomchargcol.Color:=clGray;
  end;
  if ChkboxNoCharge.Checked=False then
    lbledtatomchargcol.Color:=clDefault;
end;

procedure TForm1.lbledtxcoordcolExit(Sender: TObject);
begin
  if (lbledtxcoordcol.Text<>'') then
  begin
    lbledtycoordcol.Text:=IntToStr(StrToInt(lbledtxcoordcol.Text)+1);
    lbledtzcoordcol.Text:=IntToStr(StrToInt(lbledtxcoordcol.Text)+2);
  end;
end;

procedure TForm1.MemoDisplayInputNameMouseEnter(Sender: TObject);
begin
  MemoDisplayInputName.ScrollBars:=ssAutoBoth;
end;

end.

