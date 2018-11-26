import { NgModule } from '@angular/core';
import {
  MatSliderModule,
  MatMenuModule,
  MatButtonModule,
  MatDialogModule,
  MatToolbarModule,
  MatIconModule,
  MatCardModule,
  MatProgressSpinnerModule,
  } from '@angular/material';

@NgModule({
  exports: [
    MatSliderModule,
    MatMenuModule,
    MatButtonModule,
    MatDialogModule,
    MatToolbarModule,
    MatIconModule,
    MatCardModule,
    MatProgressSpinnerModule,
  ],
})
export class MyMaterialModule { }
