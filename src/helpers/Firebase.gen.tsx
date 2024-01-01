/* TypeScript file generated from Firebase.res by genType. */

/* eslint-disable */
/* tslint:disable */

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

export type emulatorConfig = {
  readonly protocol: string; 
  readonly host: string; 
  readonly port: (null | undefined | number)
};

export type authSettings = { readonly appVerificationDisabledForTesting: boolean };

export type userMetadata = { readonly creationTime: (null | undefined | string); readonly lastSignInTime: (null | undefined | string) };

export type userInfo = {
  readonly displayName: (null | undefined | string); 
  readonly email: (null | undefined | string); 
  readonly phoneNumber: (null | undefined | string); 
  readonly photoURL: (null | undefined | string); 
  readonly providerId: string; 
  readonly uid: string
};

export type user = {
  readonly Inherit: userInfo; 
  readonly emailVerified: boolean; 
  readonly isAnonymous: boolean; 
  readonly metadata: userMetadata; 
  readonly providerData: userInfo[]; 
  readonly refreshToken: string; 
  readonly tenantId: (null | undefined | string)
};

export type auth = {
  readonly app: firebaseApp; 
  readonly name: string; 
  readonly config: authConfig; 
  readonly languageCode: (null | undefined | string); 
  readonly tenantId: (null | undefined | string); 
  readonly settings: authSettings; 
  readonly currentUser: (null | undefined | user); 
  readonly emulatorConfig: (null | undefined | emulatorConfig)
};

export type database = { readonly app: firebaseApp; readonly type: "database" };

export type databaseReference = {
  readonly ref: databaseReference; 
  readonly isEqual: (_1:(null | undefined | query)) => boolean; 
  readonly toJSON: () => string; 
  readonly toString: () => string; 
  readonly key: (null | undefined | string); 
  readonly parent: (null | undefined | databaseReference); 
  readonly root: (null | undefined | databaseReference)
};

export type query = {
  readonly ref: databaseReference; 
  readonly isEqual: (_1:(null | undefined | query)) => boolean; 
  readonly toJSON: () => string; 
  readonly toString: () => string
};
