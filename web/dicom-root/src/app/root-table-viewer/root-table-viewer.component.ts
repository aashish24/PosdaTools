import { Component, OnInit } from '@angular/core';
import {FormControl, ReactiveFormsModule, FormGroupDirective, NgForm, Validators, FormGroup, FormBuilder} from '@angular/forms';
import {ErrorStateMatcher} from '@angular/material/core';
import {Submission} from './submission';
import { ApiService } from '../api.service';

/** Error when invalid control is dirty, touched, or submitted. From material website */
export class MyErrorStateMatcher implements ErrorStateMatcher {
  isErrorState(control: FormControl | null, form: FormGroupDirective | NgForm | null): boolean {
    const isSubmitted = form && form.submitted;
    return !!(control && control.invalid && (control.dirty || control.touched || isSubmitted));
  }
}

@Component({
  selector: 'app-root-table-viewer',
  templateUrl: './root-table-viewer.component.html',
  styleUrls: ['./root-table-viewer.component.css']
})
export class RootTableViewerComponent implements OnInit {

  private selected1 = "collection_name";
  private selected2 = "site_name";
  private input1 = "";
  private input2 = "";
  private matcher = new MyErrorStateMatcher();
  private results:Submission[];
  private addMode = false;

  private searchFormControl1 = new FormControl('', [
    //Validators.required
  ]);
  private searchFormControl2 = new FormControl('', [
    //Validators.required
  ]);

  private myNewRootForms:FormGroup;


  constructor(private myService: ApiService, private formBuilder: FormBuilder) {
    this.results =[];
    this.myNewRootForms = formBuilder.group({
      input_collection_code: ['', [Validators.required]],
      input_collection_name: ['', [Validators.required]],
      input_site_code: '',
      input_site_name: '',
      input_patient_id_prefix: '',
      input_body_part: '',
      input_access_type: '',
      input_baseline_date: '',
      input_date_shift: '',
    });
  }

  ngOnInit() {
  }



  public performSearch(){
    var param1 = this.selected1;
    var param2 = this.searchFormControl1.value;
    var param3 = this.selected2;
    var param4 = this.searchFormControl2.value;
    if (param4 == undefined || param4 == "")
      this.myService.searchRootsWithOneParam(param1,param2).subscribe(rows => this.results=rows);
    else
      this.myService.searchRootsWithTwoParams(param1,param2,param3,param4).subscribe(rows => this.results=rows);
  }

  public showAll(){
    this.myService.searchAll().subscribe(rows => this.results=rows);
  }

  public enterAddMode(){
    this.addMode = true;
    if (this.myNewRootForms.contains("input_" + this.selected1))
      this.myNewRootForms.get("input_" + this.selected1).setValue(this.searchFormControl1.value);
    if (this.myNewRootForms.contains("input_" + this.selected2))
      this.myNewRootForms.get("input_" + this.selected2).setValue(this.searchFormControl2.value);
  }

  public exitAddMode(){
    this.addMode = false;
  }

  public add(addForm){
    console.log(addForm);
  }
}