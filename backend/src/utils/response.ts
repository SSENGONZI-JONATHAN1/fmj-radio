export interface ResponseMeta {
  total?: number;
  page?: number;
  limit?: number;
  hasMore?: boolean;
  [key: string]: any;
}

export const successResponse = (data: any, meta?: ResponseMeta) => {
  return {
    success: true,
    data,
    meta,
  };
};

export const errorResponse = (message: string, code: string = 'INTERNAL_ERROR', details?: any) => {
  return {
    success: false,
    error: {
      code,
      message,
      details,
    },
  };
};
