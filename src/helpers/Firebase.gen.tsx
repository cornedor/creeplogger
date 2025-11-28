/* TypeScript file generated from Firebase.res by genType. */

/* eslint-disable */
/* tslint:disable */

import type {t as Nullable_t} from './Nullable.gen';

export type firebaseOptions = {
  readonly apiKey: string; 
  readonly authDomain: string; 
  readonly databaseURL: string; 
  readonly projectId: string; 
  readonly storageBucket: string; 
  readonly messagingSenderId: string; 
  readonly appId: string; 
  readonly measurementId: string
};

export type firebaseApp = {
  readonly name: string; 
  readonly automaticDataCollectionEnabled: boolean; 
  readonly options: firebaseOptions
};

export type authConfig = {
  readonly apiKey: string; 
  readonly apiHost: string; 
  readonly apiScheme: string; 
  readonly tokenApiHost: string; 
  readonly sdkClientVersion: string; 
  readonly authDomain: string
};

export type authSettings = { readonly appVerificationDisabledForTesting: boolean };

export type auth = {
  readonly app: firebaseApp; 
  readonly name: string; 
  readonly config: authConfig; 
  readonly languageCode: Nullable_t<string>; 
  readonly tenantId: Nullable_t<string>; 
  readonly settings: authSettings; 
  readonly currentUser: Nullable_t<user>; 
  readonly emulatorConfig: Nullable_t<emulatorConfig>
};

export type database = { readonly app: firebaseApp; readonly type: "database" };

export type databaseReference = {
  readonly ref: databaseReference; 
  readonly isEqual: (_1:Nullable_t<query>) => boolean; 
  readonly toJSON: () => string; 
  readonly toString: () => string; 
  readonly key: Nullable_t<string>; 
  readonly parent: Nullable_t<databaseReference>; 
  readonly root: Nullable_t<databaseReference>
};

export type query = {
  readonly ref: databaseReference; 
  readonly isEqual: (_1:Nullable_t<query>) => boolean; 
  readonly toJSON: () => string; 
  readonly toString: () => string
};
